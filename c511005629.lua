--Illegal Keeper
--scripted by GameMaster (GM)
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Return cards to deck & inflict 1000 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3167573,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.filter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsControler(1-tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=eg:Filter(s.filter,nil,e,tp)
	Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
	Duel.Damage(1-tp,1000,REASON_EFFECT)
end
