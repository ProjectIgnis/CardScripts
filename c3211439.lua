--禁断の異本
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
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
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=TYPE_FUSION
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=TYPE_SYNCHRO
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=TYPE_XYZ
		off=off+1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local op=Duel.SelectOption(tp,table.unpack(ops))
	e:SetLabel(opval[op])
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetLabel())
	if #g>1 then
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
