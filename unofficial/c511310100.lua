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
	--Cannot look
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCode(EFFECT_DARKNESS_HIDE)
	e2:SetValue(function(e,c) return c:GetFlagEffect(id)~=0 end)
	c:RegisterEffect(e2)
	--Rearrange
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	--Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.descon)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
s.listed_names={511310101,511310102,511310103,511310104,511310105}
function s.filter(c)
	return c:IsCode(511310101,511310102,511310103,511310104,511310105) and c:IsSSetable(true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK|LOCATION_HAND,0,1,nil):GetClassCount(Card.GetCode)==5 end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_SZONE,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsCode,1,nil,511310101) and sg:IsExists(Card.IsCode,1,nil,511310102) and
		sg:IsExists(Card.IsCode,1,nil,511310103) and sg:IsExists(Card.IsCode,1,nil,511310104) and sg:IsExists(Card.IsCode,1,nil,511310105)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_SZONE,0,e:GetHandler())
	Duel.Destroy(g,REASON_EFFECT)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<5 then return end
	Duel.BreakEffect()
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK|LOCATION_HAND,0,1,nil)
	if not s.rescon(sg) then return end
	local setg=aux.SelectUnselectGroup(sg,e,tp,5,5,s.rescon,1,tp,HINTMSG_SET)
	if #sg>0 then
		setg:ForEach(function(c)c:RegisterFlagEffect(id,RESETS_STANDARD-RESET_TOFIELD-RESET_TURN_SET,0,1)end)
		Duel.SSet(tp,setg)
		Duel.ShuffleSetCard(setg)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsTrap),tp,LOCATION_ONFIELD,0,nil)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEDOWN)
		Duel.RaiseEvent(g,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
		Duel.ShuffleSetCard(Duel.GetFieldGroup(tp,LOCATION_SZONE,0):Filter(function(c)return c:GetSequence()<5 end,nil))
		g:ForEach(function(c)c:SetStatus(STATUS_SET_TURN,true)end)
	end
end
function s.cfilter(c,tp)
	return c:GetPreviousControler()==tp and c:IsSpellTrap()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and re and re:GetHandler()~=e:GetHandler()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,0,nil,TYPE_SPELL+TYPE_TRAP)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end