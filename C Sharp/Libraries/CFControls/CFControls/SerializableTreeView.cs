using System;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System.Windows.Forms;

namespace CFControls
{
    /// <summary>
    /// Summary description for SerializableTreeView.
    /// </summary>
    ///
    [Serializable]
    public class SerializableTreeView : TreeView, ISerializable
    {
        public SerializableTreeView()
            : base()
        { }

        public SerializableTreeView(SerializationInfo info, StreamingContext context)
            : this()
        {
            SerializationInfoEnumerator infoEnumerator = info.GetEnumerator();
            while (infoEnumerator.MoveNext())
            {
                TreeNode node = info.GetValue(infoEnumerator.Name, infoEnumerator.ObjectType) as TreeNode;
                if (node != null)
                {
                    this.Nodes.Add(node);
                }
            }
        }

        public void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            foreach (TreeNode node in this.Nodes)
            {
                //info.AddValue(node.FullPath, node);
                info.AddValue(System.Guid.NewGuid().ToString(), node);
            }
        }

        /// <summary>
        /// Serialize all the nodes of this tree to the stream provided, using the formatter provided.
        /// </summary>
        /// <param name="stream">The stream to serialize to.</param>
        /// <param name="formatter">The formatter used to serialize.</param>
        public void Serialize(Stream stream, IFormatter formatter)
        {
            formatter.Serialize(stream, this);
        }

        /// <summary>
        /// Recreate this tree from a serialized version.
        /// </summary>
        /// <param name="stream">the stream that contains the serialized tree.</param>
        /// <param name="formatter">the formatter used to deserialize the stream.</param>
        public void Deserialize(Stream stream, IFormatter formatter)
        {
            // Clear our tree:
            this.Nodes.Clear();
            SerializableTreeView temp = formatter.Deserialize(stream) as SerializableTreeView;
            if (temp != null)
            {
                // copy the nodes from the temp to our tree:
                foreach (TreeNode node in temp.Nodes)
                {
                    this.Nodes.Add(node.Clone() as TreeNode);
                }
            }
        }

        public bool LoadFromFile(bool _autoload = false)
        {
            string _thefile = null;
            if (!_autoload)
            {

                OpenFileDialog dialog = new OpenFileDialog();
                dialog.AddExtension = true;
                dialog.Filter = "Data files (*.dat)|*.dat";
                if (dialog.ShowDialog() != DialogResult.OK)
                {
                    MessageBox.Show("Error Reading Data File or no Data File Selected!");
                    return false;
                }
                _thefile = dialog.FileName.ToString();
                dialog.Dispose();
            }
            else
            {
                string _mydocspath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
                _thefile = _mydocspath + @"\MyNotes.dat";
                if (!File.Exists(_thefile))
                {
                    _thefile = @"H:\MyNotes.dat";
                }
            }

            if (!File.Exists(_thefile))
            {
                return false;
            }

            try
            {
                this.Nodes.Clear();
                using (Stream stream = new FileStream(_thefile, FileMode.Open))
                {
                    IFormatter formatter = new BinaryFormatter();
                    this.Deserialize(stream, formatter);
                }
                return true;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
                return false;
            }
        }

        public bool SaveToFile()
        {
            SaveFileDialog dialog = new SaveFileDialog();
            dialog.AddExtension = true;
            dialog.FileName = "MyNotes";
            dialog.Filter = "Data files (*.dat)|*.dat";

            if (dialog.ShowDialog() != DialogResult.OK)
            {
                MessageBox.Show("Error Saving New Data or No Filename Given!");
                return false;
            }
            dialog.Dispose();

            try
            {
                using (Stream stream = new FileStream(dialog.FileName, FileMode.Create))
                {
                    IFormatter formatter = new BinaryFormatter();
                    this.Serialize(stream, formatter);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
                return false;
            }

            return true;
        }
    }
}