--ジェスター・クィーン
--Jester Queen
local s,id=GetID()
function s.initial_effect(c)
	--Destroy Spell and Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.sttg)
	e1:SetOperation(s.stop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Mulitple Attacks
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetCondition(s.condition)
	e3:SetValue(s.value)
	c:RegisterEffect(e3)
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_SZONE,0,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_SZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_SZONE,0,nil)
	Duel.Destroy(sg,REASON_EFFECT)
end
function s.condition(e)
	return not Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.value(e,c)
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil,TYPE_SPELL+TYPE_TRAP)
end