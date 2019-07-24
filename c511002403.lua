--時の魔術師
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0 end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local t={}
	local i=1
	local p=1
	for i=1,6 do t[i]=i end
	local a1=Duel.AnnounceNumber(tp,table.unpack(t))
	for i=1,6 do 
		if a1~=i then t[p]=i p=p+1 end
	end
	t[p]=nil
	local a2=Duel.AnnounceNumber(tp,table.unpack(t))
	local dc=Duel.TossDice(tp,1)
	if dc==a1 or dc==a2 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
		Duel.RaiseEvent(e:GetHandler(),71625222,e,0,0,tp,0)
		Duel.RaiseEvent(e:GetHandler(),71625222,e,0,0,1-tp,0)
	else
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
		g:AddCard(e:GetHandler())
		Duel.Destroy(g,REASON_EFFECT)
	end
end
