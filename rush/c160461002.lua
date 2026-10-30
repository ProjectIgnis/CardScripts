--Ｅ－ＨＥＲＯ ダーク・ガイア (Rush)
--Evil HERO Dark Gaia (Rush)
--scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion materials: 1 Fiend Type monster + 1 Rock Type monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),aux.FilterBoolFunctionEx(Card.IsRace,RACE_ROCK))
	--Must be Special Summoned by the effect of "Dark Fusion" or "Super Polymerization"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--This card's original ATK becomes [the total original ATK of the monsters used as material when Fusion Summoning this card].
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.sucop)
	c:RegisterEffect(e2)
	--Change up to 3 Defense Position monsters on your opponent's field to face-up Attack Position.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_DARK_FUSION,CARD_SUPER_POLYMERIZATION}
s.dark_calling=true
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(CARD_DARK_FUSION,CARD_SUPER_POLYMERIZATION)
end
function s.sucop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFusionSummoned() then
		local g=c:GetMaterial()
		local val=0
		for tc in g:Iter() do
			local a=tc:GetBaseAttack()
			if a<0 then a=0 end
			val=val+a
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.filter(c)
	return c:IsDefensePos() and c:IsCanChangePositionRush()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,3,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
end