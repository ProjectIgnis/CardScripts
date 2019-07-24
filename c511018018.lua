--Sonic Cyclone
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--count destroyed card
	aux.GlobalCheck(s,function()
		s.dt=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(s.chkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clearop)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.chkop(e,tp,eg,ev,ep,re,r,rp)
	s.dt=s.dt+eg:FilterCount(Card.IsType,nil,TYPE_MONSTER)
end
function s.clearop()
	s.dt=0
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=s.dt
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,c,TYPE_SPELL+TYPE_TRAP) end
	local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,TYPE_SPELL+TYPE_TRAP)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,ct,0,0)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local ct=s.dt
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
	if #g>=ct then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,ct,ct,nil)
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
