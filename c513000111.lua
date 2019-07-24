--最終突撃命令
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Pos Change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_POSITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,LOCATION_DECK)
	local ct1=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	local send=ct1+ct2
	if ct1>3 then send=send-3 end
	if ct2>3 then send=send-3 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,send,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
	local send=Group.CreateGroup()
	if #g1>3 then
		local sg1=g1:Select(tp,3,3,nil)
		g1:Sub(sg1)
		send:Merge(g1)
	end
	if #g2>3 then
		local sg2=g2:Select(1-tp,3,3,nil)
		g2:Sub(sg2)
		send:Merge(g2)
	end
	Duel.DisableShuffleCheck()
	Duel.SendtoGrave(send,REASON_EFFECT)
	Duel.SortDecktop(tp,tp,3)
	Duel.SortDecktop(1-tp,1-tp,3)
end
