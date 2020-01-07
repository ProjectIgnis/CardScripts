--Commande duel 25
local s,id=GetID()
function s.initial_effect(c)
	--recover
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_COIN)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.toss_coin=true
function s.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,PLAYER_ALL,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.filter,1-tp,LOCATION_MZONE,0,nil)
	local ct1=#g1
	local ct2=#g2
	if ct1==0 and ct2==0 then return end
	local op1
	local op2
	if ct1>0 then
		op1=Duel.SelectYesNo(tp,aux.Stringid(id,0))
	end
	if ct2>0 then
		op2=Duel.SelectYesNo(1-tp,aux.Stringid(id,0))
	end
	--true=wearing, false=not wearing
	local res=Duel.TossCoin(tp,1)
	local check
	if res==1 then
		check=true
	else
		check=false
	end
	if ct1>0 then
		if ((op1 and check) or (not op1 and not check)) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local lv=Duel.AnnounceNumber(tp,1,2,3,4,5,6,7,8,9,10,11,12)
			local tc=g1:GetFirst()
			while tc do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				tc=g1:GetNext()
			end
		end
	end
	if ct2>0 then
		if ((op2 and check) or (not op2 and not check)) and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
			local lv=Duel.AnnounceNumber(1-tp,1,2,3,4,5,6,7,8,9,10,11,12)
			local tc=g2:GetFirst()
			while tc do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				tc=g2:GetNext()
			end
		end
	end
end
