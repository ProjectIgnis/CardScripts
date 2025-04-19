--コピー・プラント (Anime)
--Copy Plant (Anime)
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	--Change this card's Level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(alias,0))
	e1:SetCategory(CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
end
function s.lvfilter(c,lvl)
	return c:IsFaceup() and c:HasLevel() and not c:IsLevel(lvl)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lvl=c:GetLevel()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc,lvl) end
	if chk==0 then return lvl>0 and Duel.IsExistingTarget(s.lvfilter,tp,0,LOCATION_MZONE,1,nil,lvl) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.lvfilter,tp,0,LOCATION_MZONE,1,1,nil,lvl)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--Change this card's Level
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end