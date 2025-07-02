--竜星因士－セフィラツバーン
--Satellarknight Zefrathuban
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--You cannot Pendulum Summon monsters, except "tellarknight" and "Zefra" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and not c:IsSetCard({SET_TELLARKNIGHT,SET_ZEFRA}) end)
	c:RegisterEffect(e1)
	--Destroy 1 other "tellarknight" or "Zefra" card in your Monster Zone or Pendulum Zone and 1 face-up card your opponent controls
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,0))
	e2a:SetCategory(CATEGORY_DESTROY)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetCountLimit(1,id)
	e2a:SetTarget(s.destg)
	e2a:SetOperation(s.desop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	local e2c=e2a:Clone()
	e2c:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2c:SetCondition(function(e) return e:GetHandler():IsPendulumSummoned() end)
	c:RegisterEffect(e2c)
end
s.listed_series={SET_TELLARKNIGHT,SET_ZEFRA}
function s.desfilter(c,e,tp)
	return ((c:IsControler(tp) and c:IsSetCard({SET_TELLARKNIGHT,SET_ZEFRA})) or c:IsControler(1-tp)) and c:IsFaceup()
		and c:IsCanBeEffectTarget(e)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE|LOCATION_PZONE,LOCATION_ONFIELD,e:GetHandler(),e,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,2,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end