--ホワイト・ホーンズ・バスター・ドラゴン
--White-Horned Buster Dragon
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must be Special Summoned (from your hand) while the total ATK of your banished monsters is 4000 or higher, or while you have 5 or more face-down banished cards. You can only Special Summon "White-Horned Buster Dragon" once per turn this way
	c:AddMustBeSpecialSummoned()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)
	--When your opponent activates a monster effect, or Spell Card or effect, on the field (Quick Effect): You can banish 1 card of the same type (Monster or Spell) from your GY; negate the activation, then this card gains 600 ATK. You can only use this effect of "White-Horned Buster Dragon" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return rp==1-tp and (re:IsMonsterEffect() or re:IsSpellEffect()) and Chain.IsTriggeringLocation(ev,LOCATION_ONFIELD)
			and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
	end)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_REMOVED,0,nil):GetSum(Card.GetAttack)>=4000
		or Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_REMOVED,0,5,nil))
end
function s.negcostfilter(c,effect_type)
	return c:IsType(effect_type) and c:IsAbleToRemoveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local effect_type=re:GetActiveType()&(TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP)
	if chk==0 then return Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_GRAVE,0,1,nil,effect_type) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.negcostfilter,tp,LOCATION_GRAVE,0,1,1,nil,effect_type)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,600)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.BreakEffect()
		--Negate the activation, then this card gains 600 ATK
		c:UpdateAttack(600)
	end
end