--
--Triphasic Dealmon Coordius
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.fusfilter(TYPE_SYNCHRO),s.fusfilter(TYPE_XYZ),s.fusfilter(TYPE_LINK))
	--apply effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.fusfilter(typ)
	return  function(c,fc,sumtype,tp)
				return c:IsType(typ,fc,sumtype,tp)
			end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=0
	if s.thtg(e,tp,eg,ep,ev,re,r,rp,0) then ct=ct+1 end
	if s.destg(e,tp,eg,ep,ev,re,r,rp,0) then ct=ct+1 end
	if s.atktg(e,tp,eg,ep,ev,re,r,rp,0) then ct=ct+1 end
	if chk==0 then return ct>0 and Duel.CheckLPCost(tp,2000) end
	ct=math.min(ct,math.floor(Duel.GetLP(tp)/2000))
	local t={}
	for i=1,ct do
		t[i]=i*2000
	end
	local cost=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.PayLPCost(tp,cost)
	e:SetLabel(cost)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,3,1-tp,LOCATION_ONFIELD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local opt=0
	local b1=s.thtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.destg(e,tp,eg,ep,ev,re,r,rp,0)
	local b3=s.atktg(e,tp,eg,ep,ev,re,r,rp,0)
	for i=1,ct do
		local idtable={}
		local desctable={}
		local t=1
		if b1 and (opt&1)~=0 then
			idtable[t]=1
			desctable[t]=aux.Stringid(id,1)
			t=t+1
		end
		if b1 and (opt&2)~=0 then
			idtable[t]=2
			desctable[t]=aux.Stringid(id,2)
			t=t+1
		end
		if b1 and (opt&4)~=0 then
			idtable[t]=4
			desctable[t]=aux.Stringid(id,3)
			t=t+1
		end
		if t==1 then return end
		local op=idtable[Duel.SelectOption(tp,table.unpack(desctable)) + 1]
		opt=opt+op
		if opt==1 then
			s.thop(e,tp,eg,ep,ev,re,r,rp)
		elseif opt==2 then
			s.desop(e,tp,eg,ep,ev,re,r,rp)
		elseif opt==4 then
			s.atkop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=3 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,3,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,3,3,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLP(tp)-Duel.GetLP(1-tp)~=0 end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local diff=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))
	if c:IsRelateToEffect(e) and c:IsFaceup() and diff>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(math.floor(diff/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(s.ftarget)
		e2:SetLabel(c:GetFieldID())
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,4),nil)
	end
end
function s.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
