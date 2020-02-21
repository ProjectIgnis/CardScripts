--Action Field Functions
if not ActionDuel then

	function Card.IsActionCard(c)
		return c:IsType(TYPE_ACTION) and not c.af
	end

	function Card.IsActionField(c)
		return c:IsType(TYPE_ACTION) and c.af
	end

	local tableActionGeneric={
		150000024,150000033,
		150000047,150000042,
		150000011,150000044,
		150000022,150000020
	}

	ActionDuel={}

	local function ActionDuelRules()
		local e1=Effect.GlobalEffect()
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_NO_TURN_RESET)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetCountLimit(1)
		e1:SetOperation(ActionDuel.op)
		Duel.RegisterEffect(e1,0)
		-- Add Action Card
		local e2=Effect.GlobalEffect()
		e2:SetDescription(aux.Stringid(151000000,0))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetRange(LOCATION_FZONE)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetLabelObject(e1)
		e2:SetCondition(ActionDuel.condition)
		e2:SetTarget(ActionDuel.target)
		e2:SetOperation(ActionDuel.operation)
		local e3=e2:Clone()
		e3:SetCode(EVENT_CHAINING)
		local e4=Effect.GlobalEffect()
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e4:SetLabelObject(e2)
		Duel.RegisterEffect(e4,0)
		local e5=e4:Clone()
		e5:SetLabelObject(e3)
		Duel.RegisterEffect(e5,0)
		--act ac in hand
		local e6=Effect.GlobalEffect()
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
		e6:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
		e6:SetTargetRange(0xff,0xff)
		e6:SetTarget(aux.TargetBoolFunction(Card.IsActionCard))
		Duel.RegisterEffect(e6,0)
		local e7=Effect.GlobalEffect()
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
		e7:SetCode(EFFECT_BECOME_QUICK)
		e7:SetTargetRange(0xff,0xff)
		e7:SetTarget(aux.TargetBoolFunction(Card.IsActionCard))
		Duel.RegisterEffect(e7,0)
		local e7=Effect.GlobalEffect()
		e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
		e7:SetCode(EVENT_ADJUST)
		e7:SetOperation(ActionDuel.cover)
		Duel.RegisterEffect(e7,0)
	end

	function ActionDuel.cfilter(c)
		return c:IsType(TYPE_ACTION) and c:GetFlagEffect(COVER_ACTION)==0
	end

	function ActionDuel.cover(e,tp,eg,ep,ev,re,r,rp)
		for c in aux.Next(Duel.GetMatchingGroup(ActionDuel.cfilter,0,0xff,0xff,nil)) do
			c:Cover(COVER_ACTION)
			c:RegisterFlagEffect(COVER_ACTION,0,0,0)
		end
	end

	function ActionDuel.op(e,tp,eg,ep,ev,re,r,rp)
		local actionFieldToBeUsed={}
		local announceFilter={TYPE_ACTION,OPCODE_ISTYPE,TYPE_FIELD,OPCODE_ISTYPE,OPCODE_AND}
		while #actionFieldToBeUsed==0 do
			for p=0,1 do
				if Duel.SelectYesNo(p,aux.Stringid(151000000,3)) then
					Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(151000000,4))
					local af=Duel.AnnounceCard(p,table.unpack(announceFilter))
					table.insert(actionFieldToBeUsed,af)
				end
			end
			if #actionFieldToBeUsed>0 then break
			else Duel.Hint(HINT_MESSAGE,0,aux.Stringid(151000000,5)) Duel.Hint(HINT_MESSAGE,1,aux.Stringid(151000000,5)) end
		end
		if #actionFieldToBeUsed>1 then
			Duel.Hint(HINT_MESSAGE,0,aux.Stringid(151000000,6))
			Duel.Hint(HINT_MESSAGE,1,aux.Stringid(151000000,6))
			local coin=Duel.TossCoin(0,1)
			table.remove(actionFieldToBeUsed,coin+1)
		end
		Duel.Hint(HINT_CARD,0,actionFieldToBeUsed[1])
		for p=0,1 do
			local tc=Duel.CreateToken(p,actionFieldToBeUsed[1])
			e:SetLabelObject(tc)
			--redirect
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_LEAVE_FIELD)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetOperation(function(e) Duel.SendtoDeck(e:GetHandler(),nil,-2,REASON_RULE) end)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(tc)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) 
			e2:SetCode(EVENT_CHAIN_END)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetLabelObject(tc)
			e2:SetOperation(ActionDuel.returnop)
			Duel.RegisterEffect(e2,0)
			--unaffectable
			local ea=Effect.CreateEffect(tc)
			ea:SetType(EFFECT_TYPE_SINGLE)
			ea:SetCode(EFFECT_CANNOT_TO_DECK)
			ea:SetRange(LOCATION_SZONE)
			ea:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
			tc:RegisterEffect(ea)
			local eb=ea:Clone()
			eb:SetCode(EFFECT_CANNOT_REMOVE)
			tc:RegisterEffect(eb)
			local ec=ea:Clone()
			ec:SetCode(EFFECT_CANNOT_TO_HAND)
			tc:RegisterEffect(ec)
			local ed=ea:Clone()
			ed:SetCode(EFFECT_CANNOT_TO_GRAVE)
			tc:RegisterEffect(ed)
			local ee=ea:Clone()
			ee:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			ee:SetValue(1)
			tc:RegisterEffect(ee)
			-- add ability Yell when Vanilla mode activated
			if Duel.IsExistingMatchingCard(Card.IsCode,tp,0xff,0xff,1,nil,CARD_VANILLA_MODE) then
				table.insert(tc.tableAction,CARD_POTENTIAL_YELL)
				table.insert(tc.tableAction,CARD_ABILITY_YELL)
			end
			-- move to field
			if Duel.CheckLocation(tc:GetOwner(),LOCATION_FZONE,0) then
				Duel.MoveToField(tc,tc:GetOwner(),tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true)
			else
				Duel.SendtoDeck(tc,nil,-2,REASON_RULE)
			end
		end
	end
	function ActionDuel.returnop(e)
		local c=e:GetLabelObject()
		local tp=c:GetControler()
		if Duel.CheckLocation(tp,LOCATION_FZONE,0) then
			Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end
	------------------------------------------------------------------------------
	--Check whether tp already has an Action Card in hand
	function ActionDuel.handcheck(tp)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_EARTHBOUND_TUNDRA) then
			return Duel.IsExistingMatchingCard(Card.IsActionCard,tp,LOCATION_HAND,0,2,nil)
		else
			return Duel.IsExistingMatchingCard(Card.IsActionCard,tp,LOCATION_HAND,0,1,nil)
		end
	end
	function ActionDuel.condition(e,tp,eg,ep,ev,re,r,rp)
		return (not ActionDuel.handcheck(tp) or string.find(e:GetLabelObject():GetLabelObject().af,'m'))
			and Duel.GetFlagEffect(e:GetHandlerPlayer(),320)==0
			and Duel.GetFlagEffect(e:GetHandlerPlayer(),151000000)==0
			and not e:GetHandler():IsStatus(STATUS_CHAINING)
	end
	function ActionDuel.target(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		local originalField=e:GetLabelObject():GetLabelObject()
		local t=string.find(originalField.af,'m') and originalField.tableAction or (c.tableAction and c.tableAction or (originalField.tableAction and originalField.tableAction or tableActionGeneric))
		if chk==0 then return #t>0 end
		ac=Duel.GetRandomNumber(1,#t)
		e:SetLabel(t[ac])
	end
	function ActionDuel.operation(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetCurrentChain()>0 and not Duel.SelectYesNo(tp,aux.Stringid(151000000,0)) then return end
		local originalField=e:GetLabelObject():GetLabelObject()
		if ActionDuel.handcheck(tp) and not string.find(originalField.af,'m') then return end
		local hintp,token,tokenp={}
		if not ActionDuel.handcheck(1-tp) and not (string.find(originalField.af,'t') and Duel.GetLP(tp)>Duel.GetLP(1-tp))
			and Duel.SelectYesNo(1-tp,aux.Stringid(151000000,1)) then
			local rps=Duel.RockPaperScissors(false)
			if rps<2 then
				tokenp=rps
			end
			if Duel.GetRandomNumber(0,1)==0 then table.insert(hintp,1-tp) end
		elseif Duel.TossCoin(tp,1)==1 then  
			tokenp=tp
		end
		if Duel.GetRandomNumber(0,1)==0 then table.insert(hintp,tp) end
		for _,p in ipairs(hintp) do
			Duel.Hint(HINT_MESSAGE,p,aux.Stringid(151000000,2))
			Duel.RegisterFlagEffect(p,151000000,RESET_PHASE+PHASE_END,0,1)
		end
		if tokenp then 
			token=Duel.CreateToken(tokenp,e:GetLabel())
			Duel.SendtoHand(token,nil,REASON_EFFECT)
			if string.find(originalField.af,'m') then
				table.remove(originalField.tableAction,e:GetLabel())
				Duel.RegisterFlagEffect(tp,320,RESET_PHASE+PHASE_END,0,1)
				Duel.RegisterFlagEffect(1-tp,320,RESET_PHASE+PHASE_END,0,1)
			end
		end
		if Duel.IsExistingMatchingCard(Card.IsActionCard,tokenp,LOCATION_HAND,0,2,nil)
			and Duel.Remove(token,POS_FACEUP,REASON_EFFECT) then
			local g=Duel.SelectMatchingCard(tokenp,Card.IsFaceup,tokenp,0,LOCATION_MZONE,1,1,nil)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			if g:GetCount()>0 and g:GetFirst():RegisterEffect(e1) then
				Duel.Damage(1-tokenp,300,REASON_EFFECT)
			end
		else ActionDuel.chktrap(token,tp,e) end
	end
	function ActionDuel.chktrap(tc,tp,e)
		if tc and tc:IsType(TYPE_TRAP) and tc:CheckActivateEffect(false,false,false) 
			and Duel.GetLocationCount(tp,LOCATION_SZONE) then
			Duel.ConfirmCards(1-tp,tc)
			local tpe=tc:GetType()
			local te=tc:GetActivateEffect()
			local tg=te:GetTarget()
			local co=te:GetCost()
			local op=te:GetOperation()
			e:SetCategory(te:GetCategory())
			e:SetProperty(te:GetProperty())
			Duel.ClearTargetCard()
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			Duel.Hint(HINT_CARD,0,tc:GetCode())
			tc:CreateEffectRelation(te)
			if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
			if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			for etc in aux.Next(g) do
				etc:CreateEffectRelation(te)
			end
			if op then op(te,tp,eg,ep,ev,re,r,rp) end
			tc:ReleaseEffectRelation(te)
			for etc in aux.Next(g) do
				etc:ReleaseEffectRelation(te)
			end
		end
	end

	ActionDuelRules()
	
	COVER_ACTION=301
	CARD_VANILLA_MODE=511004400
	CARD_POTENTIAL_YELL=511004399
	CARD_ABILITY_YELL=511004401
	CARD_ABILITY_YELL=511004401
	CARD_EARTHBOUND_TUNDRA=150000000

	local tableActionGeneric={
		150000024,150000033,
		150000047,150000042,
		150000011,150000044,
		150000022,150000020
	}

	local OCGActionFields={
	4064256,
	59197169,
	4545854,
	2084239,
	54306223,
	23424603,
	62188962,
	82999629,
	22702055,
	86318356,
	4215636,
	32391631,
	45778932,
	94585852,
	18161786,
	50913601,
	56074358,
	80921533,
	14001430,
	22702055,
	22751868,
	75782277,
	10080320,
	7617062,
	37694547,
	33017655,
	56594520,
	87430998,
	62265044,
	78082039,
	28120197,
	85668449,
	712559,
	35956022}
end
