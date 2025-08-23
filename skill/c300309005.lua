--Fear of the Dark
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
s.listed_names={31829185,CARD_DESTINY_BOARD} --"Dark Necrofear"
s.listed_series={SET_SPIRIT_MESSAGE}
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--"Destiny Board" and "Spirit Message" cards you control are unaffected by your opponent's card effects
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,31829185),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil) end)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(function(e,c) return c:IsFaceup() and (c:IsCode(CARD_DESTINY_BOARD) or c:IsSetCard(SET_SPIRIT_MESSAGE)) end)
	e1:SetValue(function(e,re) return e:GetOwnerPlayer()~=re:GetOwnerPlayer() end)
	Duel.RegisterEffect(e1,tp)
	--Special Summon a "Spirit Message" card as a Normal Monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)	
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(id)
	e2:SetRange(0x5f)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetCode(EVENT_ADJUST)
	e2b:SetOperation(s.altdboardop)
	Duel.RegisterEffect(e2b,tp)
	--Reveal "Spirit Message" card to draw 1 card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetRange(0x5f)
	e3:SetCondition(s.drawcon)
	e3:SetOperation(s.drawop)
	Duel.RegisterEffect(e3,tp)
end
function s.altdboardop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ALL,LOCATION_ALL,nil,CARD_DESTINY_BOARD)
	for tc in g:Iter() do
		if not tc:HasFlagEffect(id) then
			tc:RegisterFlagEffect(id,0,0,0)
			local effs={tc:GetOwnEffects()}
			for _,eff in ipairs(effs) do
				if eff:GetType()&(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)==EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F then
					eff:SetOperation(s.plop)
					eff:SetValue(s.extraop)
				end
			end
		end
	end
end
function s.plfilter(c,code)
	return c:IsCode(code) and not c:IsForbidden()
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_DARK_SANCTUARY)
		or Duel.IsPlayerAffectedByEffect(tp,id) then
		return s.extraop(e,tp,eg,ep,ev,re,r,rp)
	end
	local c=e:GetHandler()
	local code=c:GetOriginalCode()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local passcode=CARDS_SPIRIT_MESSAGE[c:GetFlagEffect(code)+1]
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(code,1))
	local g=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,1,nil,passcode)
	if #g>0 and Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		c:RegisterFlagEffect(code,RESET_EVENT|RESETS_STANDARD,0,0)
	end
end
function s.extraop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local code=c:GetOriginalCode()
	local cid=CARDS_SPIRIT_MESSAGE[c:GetFlagEffect(code)+1]
	local stzone_chk=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local dark_sanctuary_chk=Duel.IsPlayerAffectedByEffect(tp,CARD_DARK_SANCTUARY)
	local fear_of_the_dark_chk=Duel.IsPlayerAffectedByEffect(tp,id)
	local can_sp_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,cid,0,TYPE_MONSTER|TYPE_NORMAL,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp,181)
	if not (dark_sanctuary_chk or fear_of_the_dark_chk or stzone_chk) then return end
	if (dark_sanctuary_chk or fear_of_the_dark_chk) and not can_sp_chk and not stzone_chk then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(code,1))
	local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,1,nil,cid):GetFirst()
	if not sc then return end
	if not ((dark_sanctuary_chk or fear_of_the_dark_chk) and can_sp_chk) and stzone_chk then
		Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		c:RegisterFlagEffect(code,RESET_EVENT|RESETS_STANDARD,0,0)
	elseif can_sp_chk and (dark_sanctuary_chk or fear_of_the_dark_chk) then
		local op=3
		if dark_sanctuary_chk and not fear_of_the_dark_chk then
			op=(not stzone_chk or Duel.SelectYesNo(tp,aux.Stringid(CARD_DARK_SANCTUARY,0))) and 1 or 3
		elseif fear_of_the_dark_chk and not dark_sanctuary_chk then
			op=(not stzone_chk or Duel.SelectYesNo(tp,aux.Stringid(id,0))) and 2 or 3
		elseif dark_sanctuary_chk and fear_of_the_dark_chk then
			--select either or nothing
			local b1=dark_sanctuary_chk
			local b2=fear_of_the_dark_chk
			local b3=stzone_chk
			op=Duel.SelectEffect(tp,
				{b1,aux.Stringid(id,1)},
				{b2,aux.Stringid(id,2)},
				{b3,aux.Stringid(id,3)})
		end
		if op==3 then
			Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			c:RegisterFlagEffect(code,RESET_EVENT|RESETS_STANDARD,0,0)
		elseif op==1 or op==2 then
			sc:AddMonsterAttribute(TYPE_NORMAL,ATTRIBUTE_DARK,RACE_FIEND,1,0,0)
			local hint_code=op==1 and CARD_DARK_SANCTUARY or id
			Duel.Hint(HINT_CARD,0,hint_code)
			Duel.SpecialSummonStep(sc,181,tp,tp,true,false,POS_FACEUP)
			sc:AddMonsterAttributeComplete()
			if op==1 then
				--immune
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e1:SetRange(LOCATION_MZONE)
				e1:SetCode(EFFECT_IMMUNE_EFFECT)
				e1:SetValue(function(e,te) return not te:GetHandler():IsCode(CARD_DESTINY_BOARD) end)
				e1:SetReset(RESET_EVENT|RESET_TODECK|RESET_TOHAND|RESET_TOGRAVE|RESET_REMOVE)
				sc:RegisterEffect(e1)
			end
			--cannot be target
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT|RESET_TODECK|RESET_TOHAND|RESET_TOGRAVE|RESET_REMOVE)
			sc:RegisterEffect(e2)
			Duel.SpecialSummonComplete()
			c:RegisterFlagEffect(code,RESET_EVENT|RESETS_STANDARD,0,0)
		end
	end
end
--Draw functions
function s.smtdfilter(c)
	return c:IsSetCard(SET_SPIRIT_MESSAGE) and c:IsAbleToDeckAsCost() and not c:IsPublic()
end
function s.drawcon(e,tp,eg,ep,ev,re,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.smtdfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) and not Duel.HasFlagEffect(tp,id+100)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--You can only use this Skill once per turn
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
	--Place 1 "Spirit Message" card on the bottom of the Deck to draw 1 card
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.smtdfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleHand(tp)
	if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK) and Duel.IsPlayerCanDraw(tp,1) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
