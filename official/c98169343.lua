--トリックスター・キャロベイン
--Trickstar Corobane
local s,id=GetID()
function s.initial_effect(c)
	--If you control no monsters, or all monsters you control are "Trickstar" monsters: You can Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--During the Damage Step, when your "Trickstar" monster battles an opponent's monster (Quick Effect): You can send this card from your hand to the GY; that monster you control gains ATK equal to its original ATK until the end of this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.atkcon)
	e2:SetCost(Cost.SelfToGrave)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	c:RegisterEffect(e2)
end
s.listed_series={SET_TRICKSTAR}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.NOT(aux.FaceupFilter(Card.IsSetCard,SET_TRICKSTAR)),tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsDamageStep() or Duel.IsDamageCalculated() then return false end
	local bc1,bc2=Duel.GetBattleMonster(tp)
	return bc1 and bc2 and bc1:IsSetCard(SET_TRICKSTAR) and bc1:IsFaceup()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=Duel.GetBattleMonster(tp)
	if chk==0 then return bc:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,bc,1,tp,bc:GetBaseAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetBattleMonster(tp)
	if bc:IsRelateToBattle() and bc:IsControler(tp) and bc:IsFaceup() then
		--That monster you control gains ATK equal to its original ATK until the end of this turn
		bc:UpdateAttack(bc:GetBaseAttack(),RESETS_STANDARD_PHASE_END,e:GetHandler())
	end
end