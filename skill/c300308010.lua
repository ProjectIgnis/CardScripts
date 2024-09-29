--Mokey Mokey Madness
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_series={SET_MOKEY_MOKEY}
s.listed_names={13803864} --Mokey Mokey King
function s.flipcon(e)
	local tp=e:GetHandlerPlayer()
	--Condition check
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	local c=e:GetHandler()
	--Effect monsters cannot attack the turn they are Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetRange(0x5f)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(s.cannotattackcon)
	e1:SetTarget(s.cannotattacktg)
	Duel.RegisterEffect(e1,tp)
	--Choose 1 Skill to activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(0x5f)
	e2:SetCondition(s.effcon)
	e2:SetOperation(s.effop)
	Duel.RegisterEffect(e2,tp)
end
function s.cannotattackcon(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g>0 and g:FilterCount(Card.IsSetCard,nil,SET_MOKEY_MOKEY)==#g 
end
function s.cannotattacktg(e,c) 
	return c:IsType(TYPE_EFFECT) and c:IsStatus(STATUS_SUMMON_TURN|STATUS_SPSUMMON_TURN|STATUS_FLIP_SUMMON_TURN) 
end
function s.mokeycontsplfilter(c)
	return c:IsContinuousSpell() and c:IsSetCard(SET_MOKEY_MOKEY) and not c:IsForbidden()
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetFlagEffect(tp,id+100)==0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_FAIRY),tp,LOCATION_MZONE,0,2,nil)
		and Duel.IsExistingMatchingCard(s.mokeycontsplfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetFlagEffect(tp,id+200)==0
		and s.fuscost(e,tp,eg,ep,ev,re,r,rp,0)
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetFlagEffect(tp,id+100)==0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_FAIRY),tp,LOCATION_MZONE,0,2,nil)
		and Duel.IsExistingMatchingCard(s.mokeycontsplfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetFlagEffect(tp,id+200)==0
		and s.fuscost(e,tp,eg,ep,ev,re,r,rp,0)
	if not (b1 or b2) then return end

	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	--Place 1 "Mokey Mokey" Continuous Spell face-up from your Deck and if you do, destroy 1 monster you control
	if op==1 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.RegisterFlagEffect(tp,id+100,0,0,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tfg=Duel.SelectMatchingCard(tp,s.mokeyfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #tfg>0 and Duel.MoveToField(tfg:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,LOCATION_MZONE,0,1,1,nil)
			if #dg>0 then
				Duel.HintSelection(dg)
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	--Discard 1 card to Fusion Summon 1 "Mokey Mokey King"
	elseif op==2 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.RegisterFlagEffect(tp,id+200,0,0,0)
		--Discard 1 card
		s.fuscost(e,tp,eg,ep,ev,re,r,rp,1)
		--Fusion Summon 1 Fusion Monster using monsters from your hand or field as material
		local params={fusfilter=aux.FilterBoolFunction(Card.IsCode,13803864),nil,s.fextra,nil,nil}
		Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
	end
end
--Fusion Summon Functions
function s.costfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsDiscardable() then return false end
	local params={fusfilter=aux.FilterBoolFunction(Card.IsCode,13803864),extrafil=s.fextra(c)}
	return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST|REASON_DISCARD,nil,e,tp,eg,ep,ev,re,r,rp)
end
function s.fextra(exc)
	return function(e,tp,mg)
		return nil,s.fcheck(exc)
	end
end
function s.fcheck(exc)
	return function(tp,sg,fc)
		return not (exc and sg:IsContains(exc))
	end
end
