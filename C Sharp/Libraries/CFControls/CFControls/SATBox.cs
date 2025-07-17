using System;
using System.ComponentModel;

namespace CFControls
{
    /// <summary>
    /// Override for the standard System.Windows.Forms.TextBox. Allows the use of CTRL+A for selection.
    /// Update to base OnLeave event, performs a Trim() on the .Text member.
    /// </summary>
    public class SATextBox : System.Windows.Forms.TextBox
    {

        private int iNoOfDecimals = 0;
        private bool bAllowNegatives = false;
        private bool bIsDecimalPlaced = false;
        private bool bAllowSpaces = true;
        private bool bTrimWhiteSpace = true;
        private TypeOfTextbox tTextboxType = TypeOfTextbox.All;

        #region Trim Whitespace Property Grid

        [Description("Sets whether or not all whitespace at the beginning and end of the textbox should be trimmed when focus leaves the control."), DisplayName("Trim Whitespace"), Category("Advanced Behavior"), Browsable(true)]
        public bool TrimWhitespace
        {
            get { return bTrimWhiteSpace; }
            set { bTrimWhiteSpace = value; }
        }

        #endregion  Trim Whitespace Property Grid

        #region Type of Textbox Property Grid

        public enum TypeOfTextbox : byte
        {
            LettersOnly,
            NumbersOnly,
            All
        }

        [Description("Sets the type of textbox. e.g. Whether it allow only letters, only numbers or all."), DisplayName("Textbox Type"), Category("Advanced Behavior"), Browsable(true)]
        public TypeOfTextbox TextboxType
        {
            get { return tTextboxType; }
            set { tTextboxType = value; }
        }

        #endregion Type of Textbox Property Grid

        [Description("Sets the number of decimal places the textbox will round to when focus leaves the textbox. Only applicable for numbers only mode."), DisplayName("No of Decimals"), Category("Number Options"), Browsable(true)]
        public int NoOfDecimals
        {
            get { return iNoOfDecimals; }
            set { iNoOfDecimals = value; }
        }

        [Description("Sets whether the textbox allows negative numbers to be entered into the textbox. Only applicable for numbers only mode."), DisplayName("Allow Negatives"), Category("Number Options"), Browsable(true)]
        public bool AllowNegatives
        {
            get { return bAllowNegatives; }
            set { bAllowNegatives = value; }
        }

        [Description("Sets whether the textbox allows spaces to be entered into the textbox. Only applicable for letters only mode."), DisplayName("Allow Spaces"), Category("Letter Options"), Browsable(true)]
        public bool AllowSpaces
        {
            get { return bAllowSpaces; }
            set { bAllowSpaces = value; }
        }

        protected override void OnKeyDown(System.Windows.Forms.KeyEventArgs e)
        {
            if (e.Control && e.KeyCode == System.Windows.Forms.Keys.A)
            {
                this.SelectAll();
                e.Handled = true;
            }
            base.OnKeyDown(e);
        }

        protected override void OnTextChanged(EventArgs e)
        {
            base.OnTextChanged(e);
            bIsDecimalPlaced = this.Text.Contains(".");
        }

        protected override void OnKeyPress(System.Windows.Forms.KeyPressEventArgs e)
        {
            try
            {
                switch (tTextboxType)
                {
                    case TypeOfTextbox.NumbersOnly:
                        if (e.KeyChar == '-')
                        {
                            if (bAllowNegatives && this.SelectionStart == 0 && !this.Text.Contains("-"))
                                e.Handled = false;
                            else
                                e.Handled = true;
                        }
                        else if (char.IsDigit(e.KeyChar))
                        {
                            e.Handled = false;
                        }
                        else if (e.KeyChar == '\b')
                        {
                            e.Handled = false;
                        }
                        else if (iNoOfDecimals > 0 && e.KeyChar == '.' && !this.Text.Contains("."))
                        {
                            if (this.Text.Length == 0 || (this.Text == "-" && bAllowNegatives))
                            {
                                this.Text += "0.";
                                e.Handled = true;
                                this.SelectionStart = this.Text.Length;
                            }
                            else
                            {
                                e.Handled = false;
                            }
                        }
                        else
                        {
                            e.Handled = true;
                        }
                        break;

                    case TypeOfTextbox.LettersOnly:
                        #region Code for Letters Only
                        if (char.IsLetter(e.KeyChar))
                            e.Handled = false;
                        else if (e.KeyChar == '\b')
                            e.Handled = false;
                        else if (e.KeyChar == ' ' && bAllowSpaces)
                            e.Handled = false;
                        else if (e.KeyChar == '\r' && this.Multiline)
                            e.Handled = false;
                        else
                            e.Handled = true;
                        #endregion
                        break;

                    default:
                        #region Code for All
                        e.Handled = false;
                        #endregion
                        break;
                }
            }
            catch
            {
                e.Handled = false;
            }
        }

        protected override void OnLeave(EventArgs e)
        {
            try
            {
                if (bTrimWhiteSpace)
                    this.Text = this.Text.Trim();
                if (tTextboxType == TypeOfTextbox.NumbersOnly && iNoOfDecimals > 0)
                {
                    if (double.TryParse(this.Text, out double number))
                    {
                        number = System.Math.Round(number, iNoOfDecimals);
                        string format = "{0:0." + new string('0', iNoOfDecimals) + "}";
                        this.Text = String.Format(format, number);
                    } else
                    {
                        this.Text = "0";
                    }
                }
            }
            catch
            {
                this.Text = "0";
            }
            base.OnLeave(e);
        }
    }
}