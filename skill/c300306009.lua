--Dark Unity
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={CARD_SUPER_POLYMERIZATION,CARD_DARK_FUSION}
function s.flipcon(e)
	local tp=e:GetHandlerPlayer()
	local b1=Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
	local b2=Duel.GetFlagEffect(tp,id+100)==0 and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,nil,tp)
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local b1=Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
	local b2=Duel.GetFlagEffect(tp,id+100)==0 and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,nil,tp)
	--Use "Super Polymerization" to Fusion Summon monsters that normally use "Dark Fusion"
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(id)
	e1:SetRange(0x5f)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	Duel.RegisterEffect(e1,tp)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	if op==1 then
		--Lose 2000 LP, change 1 Special Summoned opponent's monster to Rock
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		Duel.SetLP(tp,Duel.GetLP(tp)-2000)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		if tc then
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_RACE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetValue(RACE_ROCK)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	elseif op==2 then
		--Discard 1 card to add 1 "Dark Fusion" from Deck to hand
		Duel.RegisterFlagEffect(tp,id+100,0,0,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		Duel.DiscardHand(tp,s.dfilter,1,1,REASON_COST+REASON_DISCARD,nil,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sc=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if sc then
			Duel.SendtoHand(sc,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sc)
		end
	end
end
function s.cfilter(c)
	return c:IsMonster() and not c:IsRace(RACE_ROCK) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.dfilter(c,tp)
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_DECK,0,1,nil)
end
function s.ffilter(c)
	return c:IsCode(CARD_DARK_FUSION) and c:IsAbleToHand()
end
