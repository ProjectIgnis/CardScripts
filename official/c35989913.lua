--永遠の絆
--Endless Bond
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: You can Special Summon 1 "Number 39: Utopia" from your GY, and if you do, it gains ATK equal to the total ATK of all LIGHT "Utopia" and "Utopic" Xyz Monsters in your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Make that monster you control lose 1000 ATK, and if you do, it can attack again in a row
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_XYZ,SET_UTOPIA,SET_UTOPIC}
s.listed_names={84013237} --"Number 39: Utopia"
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsCode(84013237) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.utopigyfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsSetCard({SET_UTOPIA,SET_UTOPIC}) and c:IsXyzMonster()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
			local atk=Duel.GetMatchingGroup(s.utopigyfilter,tp,LOCATION_GRAVE,0,nil):GetSum(Card.GetAttack)
			--It gains ATK equal to the total ATK of all LIGHT "Utopia" and "Utopic" Xyz Monsters in your GY
			sc:UpdateAttack(atk,RESET_EVENT|RESETS_STANDARD,e:GetHandler())
		end
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=eg:GetFirst()
	return bc==Duel.GetAttacker() and bc:IsControler(tp) and bc:CanChainAttack() and bc:IsSetCard({SET_UTOPIA,SET_UTOPIC})
		and bc:IsOriginalAttribute(ATTRIBUTE_LIGHT) and bc:GetBattleTarget():IsPreviousControler(1-tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=eg:GetFirst()
	e:SetLabelObject(bc)
	bc:CreateEffectRelation(e)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	--Make that monster you control lose 1000 ATK, and if you do, it can attack again in a row
	if bc:IsRelateToEffect(e) and bc:IsControler(tp) and bc:IsFaceup() and not bc:IsImmuneToEffect(e)
		and bc:UpdateAttack(-1000,RESET_EVENT|RESETS_STANDARD,e:GetHandler())<0 then
		Duel.ChainAttack()
	end
end