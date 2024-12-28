--Believe in your Bro
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
s.listed_series={SET_ELEMENTAL_HERO,SET_ROID}
function s.op(e,tp,eg,ep,ev,re,r,rp)
    	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local b1=g:FilterCount(Card.IsSetCard,nil,SET_ELEMENTAL_HERO)>0 and Duel.IsExistingMatchingCard(s.discardtrapfilter,tp,LOCATION_HAND,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) and not Duel.HasFlagEffect(tp,id)
    	local b2=g:FilterCount(s.machineroidfilter,nil)>0 and Duel.IsExistingMatchingCard(s.discardspellfilter,tp,LOCATION_HAND,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and ft>0 and not Duel.HasFlagEffect(tp,id+100)
    	local b3=g:FilterCount(s.roidherofilter,nil,tp)>0 and s.fuscost(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id+200)
    	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    	Duel.Hint(HINT_CARD,0,id)
    	--Apply effect
    	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0,nil)
    	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    	local b1=g:FilterCount(Card.IsSetCard,nil,SET_ELEMENTAL_HERO)>0 and Duel.IsExistingMatchingCard(s.discardtrapfilter,tp,LOCATION_HAND,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) and not Duel.HasFlagEffect(tp,id)
    	local b2=g:FilterCount(s.machineroidfilter,nil)>0 and ft>0 and Duel.IsExistingMatchingCard(s.discardspellfilter,tp,LOCATION_HAND,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and not Duel.HasFlagEffect(tp,id+100)
    	local b3=g:FilterCount(s.roidherofilter,nil,tp)>0 and s.fuscost(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id+200)
    	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)},{b3,aux.Stringid(id,2)})
    	--Discard 1 Trap to add 1 Machine "roid" to your hand and destroy 1 opponent's monster
    	if op==1 then
        	--OPD register (First Skill)
        	Duel.RegisterFlagEffect(tp,id,0,0,0)
        	--Discard 1 Trap to add 1 Machine "roid" monster to hand and destroy opponent's monster
        	if Duel.DiscardHand(tp,s.discardtrapfilter,1,1,REASON_COST|REASON_DISCARD,nil)>0 then
            		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            		local thc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
            		local atk=thc:GetAttack()
            		if Duel.SendtoHand(thc,tp,REASON_EFFECT)>0 then
                		Duel.ConfirmCards(1-tp,thc)
                		if Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
                    			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
                    			local dc=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk):GetFirst()
                    			Duel.HintSelection(dc,true)
                    			Duel.Destroy(dc,REASON_EFFECT)
                		end
            		end
        	end
    	--Discard 1 Spell to Special Summon 1 Level 6 or lower Machine "roid" or "Elemental HERO" from Deck
    	elseif op==2 then
        	--OPD Register (Second Skill)
        	Duel.RegisterFlagEffect(tp,id+100,0,0,0)
        	--Discard 1 Spell to Special Summon "roid" or "Elemental HERO" monster with its effects negated
        	if Duel.DiscardHand(tp,s.discardspellfilter,1,1,REASON_COST|REASON_DISCARD,nil)>0 then
            		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
            		if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
                		local e1=Effect.CreateEffect(e:GetHandler())
                		e1:SetType(EFFECT_TYPE_SINGLE)
                		e1:SetCode(EFFECT_DISABLE_EFFECT)
                		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
                		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD)
                		sc:RegisterEffect(e1)
            		end
        	end
	--Discard 1 card to Fusion Summon 1 Fusion monster using only "roid" or "HERO" monsters you control
	elseif op==3 then
        	local params={matfilter=Fusion.OnFieldMat(s.matfilter)}
        	--OPD register (Third Skill)
        	Duel.RegisterFlagEffect(tp,id+200,0,0,0)
        	--Discard 1 card
        	s.fuscost(e,tp,eg,ep,ev,re,r,rp,1)
        	--Fusion Summon 1 Fusion monster using only "HERO" and "roid" monsters you control
        	Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
        	Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
    	end
end
--Discard/Search/Destroy Functions
function s.discardtrapfilter(c)
	return c:IsTrap() and c:IsDiscardable(REASON_COST)
end
function s.thfilter(c)
	return c:IsLevelBelow(6) and c:IsSetCard(SET_ROID) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsMonster() and c:IsAttackBelow(atk)
end
--Discard/Special Summon functions
function s.machineroidfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsSetCard(SET_ROID)
end
function s.discardspellfilter(c)
	return c:IsSpell() and c:IsDiscardable(REASON_COST)
end
function s.spfilter(c,e,tp)
	return ((s.machineroidfilter(c) and c:IsLevelBelow(6)) or c:IsSetCard(SET_ELEMENTAL_HERO)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
--Discard/Fusion Summon functions
function s.roidherofilter(c)
	return c:IsSetCard(SET_ELEMENTAL_HERO) and Duel.IsExistingMatchingCard(s.machineroidfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.costfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsDiscardable(REASON_COST) then return false end
	local params={matfilter=Fusion.OnFieldMat(s.matfilter)}
	return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST|REASON_DISCARD,nil,e,tp,eg,ep,ev,re,r,rp)
end
function s.matfilter(c)
	return (c:IsSetCard(SET_ELEMENTAL_HERO) or c:IsSetCard(SET_ROID)) and c:IsCanBeFusionMaterial()
end
