--ミラージュ・ルーラー
--Mirage Ruler
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--Special Summon destroyed monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_BATTLE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.retcon)
	e2:SetCost(s.retcost)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		ge1:SetCondition(s.startcon)
		ge1:SetOperation(s.startop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.GlobalEffect()
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_LEAVE_FIELD)
		ge2:SetCondition(s.con)
		ge2:SetOperation(s.chkop)
		Duel.RegisterEffect(ge2,0)
		local ge3=Effect.GlobalEffect()
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_DESTROYED)
		ge3:SetCondition(s.con)
		ge3:SetOperation(s.checkop)
		Duel.RegisterEffect(ge3,0)
	end)
end
function s.startcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(0,id)==0
end
function s.startop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_BATTLE,0,1)
	s[0]=Duel.GetLP(0)
	s[1]=Duel.GetLP(1)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase()
end
function s.chkop(e,tp,eg,ep,ev,re,r,rp)
	for ec in aux.Next(eg) do
		if ec:IsLocation(LOCATION_MZONE) and not ec:IsReason(REASON_DESTROY) then
			Duel.RegisterFlagEffect(ec:GetControler(),id+1,RESET_PHASE+PHASE_BATTLE,0,1)
		end
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsMonster() and tc:IsPreviousLocation(LOCATION_MZONE) then
			tc:RegisterFlagEffect(id+tc:GetPreviousControler(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			Duel.RegisterFlagEffect(tc:GetPreviousControler(),id+2,RESET_PHASE|PHASE_END,0,1)
		end
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase() and Duel.IsTurnPlayer(1-tp) and Duel.GetFlagEffect(tp,id+1)==0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.filter(c,flag)
	return c:GetFlagEffect(flag)>0
end
function s.retfilter(c,p)
	return Duel.CheckLocation(p,LOCATION_MZONE,c:GetPreviousSequence())
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ALL-LOCATION_MZONE,LOCATION_ALL-LOCATION_MZONE,nil,id+tp)
	if chk==0 then return #g>0 and #g==Duel.GetFlagEffect(tp,id+2) and g:FilterCount(s.retfilter,nil,tp)==#g
		and g:GetClassCount(Card.GetPreviousSequence)==#g and s[tp]>=1000 end
	local sg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,#sg,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ALL-LOCATION_MZONE,LOCATION_ALL-LOCATION_MZONE,nil,id+tp)
	if #g>0 and #g==Duel.GetFlagEffect(tp,id+2) and g:FilterCount(s.retfilter,nil,tp)==#g
		and g:GetClassCount(Card.GetPreviousSequence)==#g then
		for tc in aux.Next(g) do
			Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,tc:GetPreviousPosition(),true,1<<tc:GetPreviousSequence())
			tc:SetStatus(STATUS_FORM_CHANGED,true)
		end
		if Duel.GetLP(tp)~=s[tp] then
			Duel.SetLP(tp,s[tp],REASON_EFFECT)
			Duel.BreakEffect()
			Duel.PayLPCost(tp,1000)
		end
	end
end