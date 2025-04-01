--ＷＷ－ブリザード・ベル
--Windwitch - Blizzard Bell
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Normal summon this without tributing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Inflict 500 damage to opponent
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e2:SetCost(Cost.SelfToGrave)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
end
s.listed_series={SET_WINDWITCH}
s.listed_names={id}
function s.filter(c)
	return c:IsFacedown() or not c:IsSetCard(SET_WINDWITCH)
end
function s.ntcon(e,c,minc,zone)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil))
end
function s.cfilter(c)
	return c:IsSetCard(SET_WINDWITCH) and c:IsFaceup() and not c:IsCode(id)
end
	--Check if it's opponent's main phase and player controls a "Windwitch" monster other than this card's name
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase()
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
	--Inflict 500 damage to opponent
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end