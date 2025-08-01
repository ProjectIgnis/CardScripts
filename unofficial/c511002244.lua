--ソリッドロイドα
--Solidroid α
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--There can only be 1 "Solidroid" monster on your field
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0x4016),LOCATION_MZONE)
	--Fusion Summon procedure:"Strikeroid" + "Stealthroid" + "Turboroid"
	Fusion.AddProcMix(c,true,true,511000660,98049038,511002240)
	Fusion.AddContactProc(c,s.contactfilter,s.contactop)
	--Gains ATK equal to the ATK of a monster your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.listed_series={0x4016} --"Solidroid" archetype
s.material_setcode=SET_ROID
function s.contactfilter(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,nil)
end
function s.contactop(g,tp,c)
	Duel.SendtoGrave(g,REASON_COST|REASON_FUSION|REASON_MATERIAL)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc,true)
		--Gains ATK equal to the original ATK of a monster your opponent controls until the end of the turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		c:RegisterEffect(e1)
	end
end
