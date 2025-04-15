--原石竜インペリアル・ドラゴン
--Primite Imperial Dragon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Requires 1 Normal Monster Tribute to Normal Summon face-up
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e0:SetCondition(s.selfnssumcon)
	e0:SetTarget(s.selfnssumtg)
	e0:SetOperation(s.selfnssumop)
	e0:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e0)
	--Normal Summon 1 "Primoredial" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase() end)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	--Apply effects if it is Tribute Summoned
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(function(e) return e:GetHandler():IsTributeSummoned() end)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PRIMITE}
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.tributefilter,1,nil,tp)
end
function s.tributefilter(c,tp)
	return c:IsType(TYPE_NORMAL) and (c:IsControler(tp) or c:IsFaceup())
end
function s.selfnssumcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return aux.SelectUnselectGroup(Duel.GetReleaseGroup(tp),e,tp,1,1,s.rescon,0)
end
function s.selfnssumtg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=aux.SelectUnselectGroup(Duel.GetReleaseGroup(tp),e,tp,1,1,s.rescon,1,tp,HINTMSG_RELEASE,nil,nil,Duel.IsSummonCancelable())
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.selfnssumop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON|REASON_COST|REASON_MATERIAL)
	g:DeleteGroup()
end
function s.sumfilter(c)
	return c:IsSetCard(SET_PRIMITE) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,1,tp,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end
function s.rmvfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToRemove()
		and Duel.IsExistingMatchingCard(s.matchfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetRace(),c:GetAttribute())
end
function s.matchfilter(c,race,att)
	return c:IsType(TYPE_NORMAL) and (c:IsRace(race) or c:IsAttribute(att))
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local disg=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,nil)
	local rmvg=Duel.GetMatchingGroup(s.rmvfilter,tp,0,LOCATION_MZONE,nil,tp)
	if chk==0 then return #disg>0 or #rmvg>0 end
	if #disg>0 then
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,disg,#disg,tp,0)
	end
	if #rmvg>0 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rmvg,#rmvg,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local break_chk=false
	local disg=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,nil):Filter(Card.IsCanBeDisabledByEffect,nil,e)
	--Negate the effects of all face-up monsters your opponent controls 
	for tc in disg:Iter() do
		tc:NegateEffects(c)
		Duel.AdjustInstantly(tc)
		break_chk=true
	end
	--Banish all monsters with the same Type/Attributes as Normal Monsters in your GY
	local rmvg=Duel.GetMatchingGroup(s.rmvfilter,tp,0,LOCATION_MZONE,nil,tp)
	if #rmvg>0 then
		if break_chk then Duel.BreakEffect() end
		Duel.Remove(rmvg,POS_FACEUP,REASON_EFFECT)
	end
end