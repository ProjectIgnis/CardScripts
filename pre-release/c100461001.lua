--極限を超えし者－バスター・ブレイダー
--Buster Blader, the One Who Surpasses the Limits
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is in your hand or GY: You can discard 1 Spell; Special Summon this card, and if you do, its name becomes "Buster Blader", also banish it when it leaves the field. You can only use this effect of "Buster Blader, the One Who Surpasses the Limits" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.Discard(Card.IsSpell))
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	--Gains 500 ATK for each Attack Position monster your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,c)
		return 500*Duel.GetMatchingGroupCount(Card.IsAttackPos,c:GetControler(),0,LOCATION_MZONE,nil)
	end)
	c:RegisterEffect(e2)
	--When this card destroys a monster by battle: You can discard 1 card; Special Summon that monster to your field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(aux.bdcon)
	e3:SetCost(Cost.Discard())
	e3:SetTarget(s.battlesptg)
	e3:SetOperation(s.battlespop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_BUSTER_BLADER}
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		--Its name becomes "Buster Blader"
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(CARD_BUSTER_BLADER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
		--Also banish it when it leaves the field
		local e2=e1:Clone()
		e2:SetDescription(3300)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end
function s.battlesptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsFaceup() and not bc:IsType(TYPE_TOKEN)
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	bc:CreateEffectRelation(e)
	e:GetChainData().destroyed_monster=bc
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,tp,0)
end
function s.battlespop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetChainData().destroyed_monster
	if bc:IsRelateToEffect(e) then
		Duel.SpecialSummon(bc,0,tp,tp,false,false,POS_FACEUP)
	end
end