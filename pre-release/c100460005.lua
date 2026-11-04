--方界領域
--Cubic Dimension
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: You can add 1 Level 4 or lower "Cubic" monster from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Neither player takes any battle damage from battles involving 2 monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,1)
	e2:SetCondition(function(e)
		return Duel.GetAttacker() and Duel.GetAttackTarget()
	end)
	c:RegisterEffect(e2)
	--Once per turn, during your Main Phase: You can Special Summon 1 "Cubic" monster from your hand, ignoring its Summoning conditions
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--If a monster(s) is destroyed by battle: Its controller takes damage equal to its original ATK
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_CUBIC}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(SET_CUBIC) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_CUBIC) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local damage=0
	local chain_data=e:GetChainData()
	local p0_group,p1_group=eg:Split(Card.IsPreviousControler,nil,0)
	if #p0_group>0 then
		chain_data.p0_damage=p0_group:GetSum(Card.GetBaseAttack)
		damage=chain_data.p0_damage
	end
	if #p1_group>0 then
		chain_data.p1_damage=p1_group:GetSum(Card.GetBaseAttack)
		damage=damage+chain_data.p1_damage
	end 
	local opinfo_player=(#p0_group>0 and #p1_group>0 and PLAYER_ALL)
		or (#p0_group>0 and 0)
		or (#p1_group>0 and 1)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,opinfo_player,damage)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local chain_data=e:GetChainData()
	local p0_damage=chain_data.p0_damage
	local p1_damage=chain_data.p1_damage
	if p0_damage and p0_damage>0 then
		Duel.Damage(0,p0_damage,REASON_EFFECT,true)
	end
	if p1_damage and p1_damage>0 then
		Duel.Damage(1,p1_damage,REASON_EFFECT,true)
	end
	Duel.RDComplete()
end