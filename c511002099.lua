--Agent of Hatred
local s,id=GetID()
function s.initial_effect(c)
	--gain lp
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.reccon)
	e1:SetTarget(s.rectg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=0
		--register
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DAMAGE)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s[0]>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local i=1
	local ct=s[0]
	local rg=Group.CreateGroup()
	local dam=0
	while i<ct do
		rg:AddCard(s[i])
		i=i+2
	end
	local sc=rg:Select(tp,1,1,nil):GetFirst()
	local multiatk=false
	i=1
	while i<ct and sc~=s[i] do
		i=i+2
	end
	dam=s[i+1]
	t=i+2
	while i<ct do
		if sc==s[i] then
			multiatk=true
		end
		i=i+2
	end
	if multiatk then
		i=1
		local t={}
		local p=1
		while i<ct do
			if sc==s[i] then
				t[p]=s[i+1]
				p=p+1
			end
			i=i+2
		end
		t[p]=nil
		dam=Duel.AnnounceNumber(tp,table.unpack(t))
	end
	Duel.Recover(p,dam,REASON_EFFECT)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if ep==1-Duel.GetTurnPlayer() then
		local ct=s[0]
		s[ct+1]=eg:GetFirst()
		s[ct+2]=ev
		s[0]=ct+2
	end
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	local ct=s[0]
	if ct>0 then
		local i=1
		while s[i]~=nil do
			s[i]=nil
			i=i+1
		end
		s[0]=0
	end
end
