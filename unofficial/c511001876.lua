--Raidraptor - Rig
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
function s.filter(c)
	return c:IsFaceup() and c:GetLevel()>0 and not c:IsRace(RACE_WINGEDBEAST)
end
function s.filter2(c,lv)
	return c:IsFaceup() and c:GetLevel()==lv and not c:IsRace(RACE_WINGEDBEAST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tg=g:GetMinGroup(Card.GetLevel)
	local lv=tg:GetFirst():GetLevel()
	local t={}
	local p=1
	while #g>0 do 
		t[p]=lv
		p=p+1
		g:Sub(tg)
		if #g>0 then
			tg=g:GetMinGroup(Card.GetLevel)
			lv=tg:GetFirst():GetLevel()
		end
	end
	t[p]=nil
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	Duel.SetTargetParam(Duel.AnnounceNumber(tp,table.unpack(t)))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil,lv)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(RACE_WINGEDBEAST)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
