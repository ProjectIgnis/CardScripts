--星遺物－『星鍵』
--World Legacy - "World Key"
local s,id=GetID()
function s.initial_effect(c)
	--Apply a "you can Tribute Summon 1 monster during your Main Phase this turn, in addition to your Normal Summon/Set" effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalTributeSummon(tp) end)
	e1:SetCost(Cost.Discard(function(c) return c:IsSetCard(SET_WORLD_LEGACY) end))
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Return 1 opponent's Link Monster that this card battles to the Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.rtexcon)
	e2:SetTarget(s.rtextg)
	e2:SetOperation(s.rtexop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_WORLD_LEGACY}
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanAdditionalTributeSummon(tp) then return end
	local c=e:GetHandler()
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2))
	--You can Tribute Summon 1 monster during your Main Phase this turn, in addition to your Normal Summon/Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	Duel.RegisterEffect(e2,tp)
end
function s.rtexcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsRelateToBattle() and bc:IsControler(1-tp) and bc:IsLinkMonster()
end
function s.rtextg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsAbleToExtra() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,bc,1,tp,0)
end
function s.rtexop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		Duel.SendtoDeck(bc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end