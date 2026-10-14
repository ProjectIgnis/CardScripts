--ＥＭパイロブスター
--Performapal Pyrobster
local s,id=GetID()
function s.initial_effect(c)
	--Once per turn: You can choose 2 "Performapal" monsters in your Graveyard, whose total Levels equal 12 or less, then target 1 monster on the field; its Level becomes equal to the total Levels of those 2 chosen monsters.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93543806,0))
	e1:SetCategory(CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_PERFORMAPAL}
function s.lvlfilter(c,tp)
	return c:HasLevel() and c:IsSetCard(SET_PERFORMAPAL)
		and Duel.IsExistingTarget(s.lvlsumfilter,tp,LOCATION_GRAVE,0,1,c,c:GetLevel())
end
function s.lvlsumfilter(c,lvl)
	return c:HasLevel() and c:IsSetCard(SET_PERFORMAPAL) and (c:GetLevel()+lvl)<=12
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(s.lvlfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectMatchingCard(tp,s.lvlfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g2=Duel.SelectMatchingCard(tp,s.lvlsumfilter,tp,LOCATION_GRAVE,0,1,1,g1:GetFirst(),g1:GetFirst():GetLevel())
	local lvl=g1:GetFirst():GetLevel()+g2:GetFirst():GetLevel()
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.HasLevel),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lvl)
	e:SetLabel(lvl)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,nil,1,tp,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
