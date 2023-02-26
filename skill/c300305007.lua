--HERO World
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabelObject(e)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local b1=#g>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_EARTH)>0 and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_MZONE,1,nil)
	local b2=#g>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WIND)>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSpellTrap),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b3=#g>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_FIRE)>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b4=#g>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WATER)>0 and Duel.IsPlayerCanDraw(tp,1)
	local b5=#g>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_LIGHT)>0 and Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) and (b1 or b2 or b3 or b4 or b5)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	--Discard Hand
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	--Apply effect
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local b1=#g>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_EARTH)>0 and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_MZONE,1,nil)
	local b2=#g>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WIND)>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSpellTrap),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b3=#g>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_FIRE)>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b4=#g>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WATER)>0 and Duel.IsPlayerCanDraw(tp,1)
	local b5=#g>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_LIGHT)>0 and Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)},{b3,aux.Stringid(id,2)},{b4,aux.Stringid(id,3)},{b5,aux.Stringid(id,4)})
	--Destroy 1 EARTH monster you control and 1 face-up opponent's monster
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local pg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local og=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_MZONE,1,1,nil)
		pg:Merge(og)
		Duel.HintSelection(pg)
		Duel.Destroy(pg,REASON_EFFECT)
	--Destroy 1 face-up Spell/Trap on field
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSpellTrap),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	--Return all non-FIRE Special Summoned monsters on field to hand
	elseif op==3 then
		local rg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Filter(s.thfilter,nil)
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	--Draw 1 card, also you can activate 1 Normal Trap from your hand until the end of the next turn
	elseif op==4 then
		Duel.Draw(tp,1,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
		e1:SetTargetRange(LOCATION_HAND,0)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
	--Change 1 monster's battle position on field
	elseif op==5 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local tc=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
--Destroy filter
function s.desfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_EARTH)
end
--HERO Normal/Fusion check
function s.cfilter(c)
	return c:IsSetCard(0x8) and (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_FUSION)) and c:IsMonster()
end
--Returnable to hand
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsSummonType(SUMMON_TYPE_SPECIAL) and not c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceup()
end
--Changeable position
function s.posfilter(c)
	return c:IsMonster() and c:IsFaceup() and c:IsCanChangePosition()
end