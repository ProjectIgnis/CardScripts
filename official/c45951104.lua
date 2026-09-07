--ボット・ハーダー
--Bot Herder
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Apply these effects in sequence
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.efftgfilter(c,tp)
	return (c:IsOwner(tp) and c:IsFaceup()) or c:IsPosition(POS_FACEDOWN_DEFENSE)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and s.efftgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.efftgfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.efftgfilter,tp,0,LOCATION_MZONE,1,1,nil,tp):GetFirst()
	if tc:IsFaceup() then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,200)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,200)
	Duel.SetPossibleOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
		if tc:IsOwner(1-tp) then return end
	else tc=nil end
	--Inflict 200 damage to your opponent
	Duel.Damage(1-tp,200,REASON_EFFECT)
	--Take control of all monsters your opponent controls, except that monster
	local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,tc,true)
	if #g>0 then
		Duel.BreakEffect()
		Duel.GetControl(g,tp)
	end
end