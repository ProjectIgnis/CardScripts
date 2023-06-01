--禁断の異本
--Forbidden Apocrypha
local s,id=GetID()
function s.initial_effect(c)
	--Make players send monsters to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tpe)
	return c:IsFaceup() and c:IsType(tpe)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,TYPE_FUSION)
	local b2=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,TYPE_SYNCHRO)
	local b3=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,TYPE_XYZ)
	if chk==0 then return b1 or b2 or b3 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{b3,aux.Stringid(id,2)})
	local opval={TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ}
	e:SetLabel(opval[op])
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,e:GetLabel())
	local g2=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	if #g1>0 then
		Duel.SendtoGrave(g1,REASON_RULE,PLAYER_NONE,tp)
	end
	if #g2>0 then
		Duel.SendtoGrave(g2,REASON_RULE,PLAYER_NONE,1-tp)
	end
end