--オーバーレイ・リバース
--Overlay Rebirth
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingTarget(Card.IsMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,Card.IsMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,2,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg<3 then return end
	local tc=tg:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
	local mat=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if tc and tc:IsRelateToEffect(e) and tc:IsType(TYPE_XYZ) and tc:IsFaceup() and not tc:IsImmuneToEffect(e)
		and #mat==2 then
		Duel.Overlay(tc,mat)
	end
end