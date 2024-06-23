--ジャイアント・タコーン
--Giant Kra-Corn
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand in Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Make the ATK of this card and another Plant monster you control become their total original ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		local ac=Duel.GetAttacker()
		if ac:CanAttack() and not ac:IsImmuneToEffect(e) then
			Duel.CalculateDamage(ac,c)
		end
	end
end
function s.atkfilter(c,atk,original_atk)
	local total_original_atk=original_atk+c:GetBaseAttack()
	return c:IsRace(RACE_PLANT) and not c:IsCode(id) and c:IsFaceup() and not (c:IsAttack(total_original_atk) and atk==total_original_atk)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	local original_atk=c:GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc,atk,original_atk) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,c,atk,original_atk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,c,atk,original_atk)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and c:IsFaceup() and tc:IsFaceup() then
		--Their ATK becomes the combined original ATK of both cards
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(c:GetBaseAttack()+tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
	end
end