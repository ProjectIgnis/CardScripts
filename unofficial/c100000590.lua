--ダークネス
--Darkness
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCode(EFFECT_DARKNESS_HIDE)
	e2:SetValue(function(e,c) return c:GetFlagEffect(id)~=0 end)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsCode(id+1,100000592,100000593,100000594,100000595) and c:IsSSetable()
end
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDestructable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil):GetClassCount(Card.GetCode)==5 end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	Duel.Destroy(g,REASON_EFFECT)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=4 then return end 
	Duel.BreakEffect()
	--darkness
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil)
	if sg:GetClassCount(Card.GetCode)<5 then return end
	if #sg==5 then
		sg:ForEach(function(c)c:RegisterFlagEffect(id,RESETS_STANDARD-RESET_TOFIELD-RESET_TURN_SET,0,1)end)
		Duel.SSet(tp,sg)
	else
		local setg=Group.CreateGroup()
		while #setg<5 do
			local tc=sg:Filter(function(c)return not setg:IsExists(Card.IsCode,nil,1,c:GetCode())end,nil):SelectUnselect(setg,tp)
			if setg:IsContains(tc) then
				setg=setg-tc
			else
				setg=setg+tc
			end
		end
		setg:ForEach(function(c)c:RegisterFlagEffect(id,RESETS_STANDARD-RESET_TOFIELD-RESET_TURN_SET,0,1)end)
		Duel.SSet(tp,setg)
	end
end
function s.cfilter(c,tp)
	return c:GetPreviousControler()==tp and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and re:GetHandler()~=e:GetHandler()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
function s.setfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_ONFIELD,0,nil)
	for tc in aux.Next(g) do
		Duel.ChangePosition(tc,POS_FACEDOWN)
		Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
	Duel.ShuffleSetCard(Duel.GetFieldGroup(tp,LOCATION_SZONE,0):Filter(function(c)return c:GetSequence()<5 end,nil))
end