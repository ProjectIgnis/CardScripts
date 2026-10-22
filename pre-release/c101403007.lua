--アマゾネスの呪詛師－呪印の舞い－
--Amazoness Spellcaster - Forbidden Spell Dance
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can add 1 "Amazoness" monster from your Deck to your hand, except a Level 3 monster
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetTarget(s.thtg)
	e1a:SetOperation(s.thop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--During your Main Phase: You can Fusion Summon 1 EARTH or WIND Fusion Monster from your Extra Deck, using monsters from your hand or field
	local fusion_params={
		fusfilter=function(c)
			return c:IsAttribute(ATTRIBUTE_EARTH|ATTRIBUTE_WIND)
		end
	}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(Fusion.SummonEffTG(fusion_params))
	e2:SetOperation(Fusion.SummonEffOP(fusion_params))
	c:RegisterEffect(e2)
	--During damage calculation, if your "Amazoness" monster battles an opponent's monster: You can banish this card from your GY; switch the battling monsters' ATK until the end of this turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.atkcon)
	e3:SetCost(Cost.SelfBanish)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_AMAZONESS}
function s.thfilter(c)
	return c:IsSetCard(SET_AMAZONESS) and c:IsMonster() and not c:IsLevel(3) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local bc1=Duel.GetBattleMonster(tp)
	if not (bc1 and bc1:IsSetCard(SET_AMAZONESS)) then return false end
	local bc2=bc1:GetBattleTarget()
	return bc2 and bc2:IsControler(1-tp) and not bc1:IsAttack(bc2:GetAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc1=Duel.GetBattleMonster(tp)
	local bc2=bc1:GetBattleTarget()
	if bc1:IsRelateToBattle() and bc2:IsRelateToBattle() then
		local c=e:GetHandler()
		local atk1=bc1:GetAttack()
		local atk2=bc2:GetAttack()
		--Switch the battling monsters' ATK until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk2)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		bc1:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetValue(atk1)
		bc2:RegisterEffect(e2)
	end
end