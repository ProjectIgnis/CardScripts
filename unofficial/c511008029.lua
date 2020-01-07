--Reverse Wall
--	by Snrk
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.cd)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

function s.desg(p) return Duel.GetMatchingGroup(Card.IsDestructable,p,0,LOCATION_MZONE,nil) end
function s.exist(p) return Duel.IsExistingMatchingCard(Card.IsDestructable,p,0,LOCATION_MZONE,1,nil) end
function s.cf(c,p) return c:GetPreviousControler()==p and c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER) and c:GetPreviousDefenseOnField()>=2000 end

function s.cd(e,tp,eg) return eg:IsExists(s.cf,1,nil,tp) end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.exist(tp) end
	local g=s.desg(tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.op(e,tp)
	if not s.exist(tp) then return end
	Duel.Destroy(s.desg(tp),REASON_EFFECT)
end








