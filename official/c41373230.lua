--灰燼竜バスタード
--Titaniklad the Ash Dragon
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon procedure
	Fusion.AddProcMix(c,true,true,CARD_ALBAZ,aux.FilterBoolFunctionEx(Card.IsAttackAbove,2500))
	--Verify materials
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	c:RegisterEffect(e1)
	--Increase its ATK by the level of its materials x 100
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e2:SetOperation(s.atkop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--Unaffected by activated effects of monster Special Summoned from the Exra Deck
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	--Register effect when it is sent to the GY
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetOperation(s.regop2)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_ALBAZ}
s.listed_series={SET_DOGMATIKA}
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local atk=0
	for tc in g:Iter() do
		atk=atk+tc:GetOriginalLevel()
	end
	e:SetLabel(atk)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=e:GetLabelObject():GetLabel()*100
	if atk>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFusionSummoned() then return end
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.efilter)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return tc:IsSpecialSummoned() and tc:IsSummonLocation(LOCATION_EXTRA) and tc~=e:GetHandler()
		and te:IsMonsterEffect() and te:IsActivated() and te:GetActivateLocation()==LOCATION_MZONE
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	--Add to hand or Special Summom 1 "Dogmatika" monster or "Fallen of Albaz"
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
end
function s.thfilter(c,e,tp,ft)
	return c:IsMonster() and (c:IsSetCard(SET_DOGMATIKA) or c:IsCode(CARD_ALBAZ))
		and (c:IsAbleToHand() or (c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft):GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp,function(c)
			return tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0 end,
		function(c)
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,1))
	end
end