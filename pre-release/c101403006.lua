--アマゾネスの格闘戦士－蹴殺の舞い－
--Amazoness Fighter - Instant Kill Dance
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If this card is added to your hand, except by drawing it: You can Special Summon it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return not e:GetHandler():IsReason(REASON_DRAW)
	end)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	--If this card is Normal or Special Summoned: You can Set 1 Spell/Trap from your Deck that mentions "Harpie Lady"
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_SET)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetTarget(s.settg)
	e2a:SetOperation(s.setop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	--During damage calculation, if your "Amazoness" monster battles an opponent's monster: You can activate this effect; for that battle, neither monster can be destroyed by battle, also you take no battle damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.battlecon)
	e3:SetOperation(s.battleop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_HARPIE_LADY}
s.listed_series={SET_AMAZONESS}
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.setfilter(c)
	return c:IsSpellTrap() and c:ListsCode(CARD_HARPIE_LADY) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
function s.battlecon(e,tp,eg,ep,ev,re,r,rp)
	local your_monster,opp_monster=Duel.GetBattleMonster(tp)
	return your_monster and opp_monster and your_monster:IsSetCard(SET_AMAZONESS)
end
function s.battleop(e,tp,eg,ep,ev,re,r,rp)
	local your_monster,opp_monster=Duel.GetBattleMonster(tp)
	if your_monster:IsRelateToBattle() and opp_monster:IsRelateToBattle() then
		local c=e:GetHandler()
		--For that battle, neither monster can be destroyed by battle
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
		your_monster:RegisterEffect(e1)
		local e2=e1:Clone()
		opp_monster:RegisterEffect(e2)
		--Also you take no battle damage
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e3:SetTargetRange(1,0)
		e3:SetReset(RESET_PHASE|PHASE_DAMAGE_CAL)
		Duel.RegisterEffect(e3,tp)
	end
end