--血肉の代償
--Terminal Offering
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Allow up to 3 Normal Summons
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(_,tp) return Duel.IsMainPhase() and Duel.IsTurnPlayer(tp) end)
	e2:SetCost(s.cost(1000))
	e2:SetTarget(s.trisumtg)
	e2:SetOperation(s.trisumop)
	c:RegisterEffect(e2)
	--Normal Summon 1 monster during your opponent's Battle Phase
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetHintTiming(0,TIMING_BATTLE_START)
	e3:SetCondition(function(_,tp) return Duel.IsBattlePhase() and Duel.IsTurnPlayer(1-tp) end)
	e3:SetCost(s.cost(500))
	e3:SetTarget(s.nstg)
	e3:SetOperation(s.nsop)
	c:RegisterEffect(e3)
end
function s.cost(lpcost)
	return function (e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.CheckLPCost(tp,lpcost) end
		Duel.PayLPCost(tp,lpcost)
	end
end
function s.trisumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=0
		local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
		for _,te in ipairs(ce) do
			ct=math.max(ct,te:GetValue())
		end
		return ct<3
	end
end
function s.trisumop(e,tp,eg,ep,ev,re,r,rp)
	--Player can Normal Summon/Set up to 3 times
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetTargetRange(1,0)
	e1:SetValue(3)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,true,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,true,nil):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end
