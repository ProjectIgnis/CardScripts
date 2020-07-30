if not DeckMaster then
	DeckMaster={}
	DeckMasterZone={}
	FLAG_DECK_MASTER = 300

	--function that return the flag that check if a monster is treated as a Deck Master
	function Card.IsDeckMaster(c)
		return c:GetFlagEffect(FLAG_DECK_MASTER)>0
	end
	--function that
	function Duel.GetDeckMaster(p)
		return DeckMasterZone[p] or Duel.GetMatchingGroup(Card.IsDeckMaster,p,LOCATION_MZONE,0,nil):GetFirst()
	end
	-- function that send a card to the DM zone
	-- add the card to the Skill zone, register the DMzone flag then send the card to limbo
	function Card.MoveToDeckMasterZone(c,p)
		Duel.Hint(HINT_SKILL,p,c:GetOriginalCode())
		Duel.SendtoDeck(c,nil,-2,REASON_RULE)
		DeckMasterZone[p]=c
	end
	--function that remove the card from the DM/Skill zone
	function Card.RemoveFromDeckMasterZone(c,p)
		Duel.Hint(HINT_SKILL_REMOVE,p,c:GetOriginalCode())
		DeckMasterZone[p]=nil
	end
	--function that summon the monster from the DMzone
	--remove from DMzone, remove the DMzone flag, summon the deck master
	function Card.SummonDeckMaster(c,p)
		c:RemoveFromDeckMasterZone(p)
		Duel.SpecialSummon(c,0,p,p,false,false,POS_FACEUP)
		c:RegisterFlagEffect(FLAG_DECK_MASTER,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_CONTROL,EFFECT_FLAG_CLIENT_HINT,1,nil,aux.Stringid(153000000,1))
	end

	function DeckMaster.RegisterRules()
		if Duel.GetFlagEffect(0,FLAG_DECK_MASTER)>0 then return end
		Duel.RegisterFlagEffect(0,FLAG_DECK_MASTER,0,0,0)
		--Summon Deck Master
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCondition(DeckMaster.spcon)
		e1:SetOperation(DeckMaster.spop)
		Duel.RegisterEffect(e1,0)
		local e2=e1:Clone()
		Duel.RegisterEffect(e2,1)
		--Lose
		local e3=Effect.GlobalEffect()
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e3:SetCountLimit(1)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e3:SetOperation(DeckMaster.loss)
		Duel.RegisterEffect(e3,0)
		local e4=e3:Clone()
		e4:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
		Duel.RegisterEffect(e4,0)
		local e5=e3:Clone()
		e5:SetCode(EVENT_PHASE_START+PHASE_MAIN1)
		Duel.RegisterEffect(e5,0)
		local e6=e3:Clone()
		e6:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
		Duel.RegisterEffect(e6,0)
		local e7=e3:Clone()
		e7:SetCode(EVENT_PHASE_START+PHASE_MAIN2)
		Duel.RegisterEffect(e7,0)
		local e8=e3:Clone()
		e8:SetCode(EVENT_PHASE_START+PHASE_END)
		Duel.RegisterEffect(e8,0)
		--Deck Master inheritance
		local e9=Effect.GlobalEffect()
		e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e9:SetCode(EVENT_LEAVE_FIELD_P)
		e9:SetCondition(DeckMaster.inheritcon1)
		e9:SetOperation(DeckMaster.inheritop1)
		Duel.RegisterEffect(e9,0)
		local e10=e9:Clone()
		e10:SetCode(EVENT_SUMMON_SUCCESS)
		e10:SetCondition(DeckMaster.inheritcon2)
		e10:SetOperation(DeckMaster.inheritop2)
		Duel.RegisterEffect(e10,0)
		local e11=e10:Clone()
		e11:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		Duel.RegisterEffect(e11,0)
		local e12=e10:Clone()
		e12:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		Duel.RegisterEffect(e12,0)
	end

	function DeckMaster.inheritcon1(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(Card.IsDeckMaster,1,nil)
	end
	function DeckMaster.inheritop1(e,tp,eg,ep,ev,re,r,rp)
		local g=eg:Filter(Card.IsDeckMaster,nil)
		for tc in aux.Next(g) do
			if tc:GetReason()&REASON_BATTLE==0 and tc:GetReasonCard() then
				tc:GetReasonCard():RegisterFlagEffect(FLAG_DECK_MASTER,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_CONTROL,EFFECT_FLAG_CLIENT_HINT,1,nil,aux.Stringid(153000000,1))
			end
		end
	end

	function DeckMaster.inheritFilter(c)
		return not Duel.GetDeckMaster(c:GetControler()) and c:GetControler()==c:GetSummonPlayer()
	end
	function DeckMaster.inheritcon2(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(DeckMaster.inheritFilter,1,nil)
	end
	function DeckMaster.inheritop2(e,tp,eg,ep,ev,re,r,rp)
		local g=eg:Filter(DeckMaster.inheritFilter,nil)
		for p=0,1 do
			local dg=g:Filter(Card.IsControler,nil,p)
			if #dg>0 then
				Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(153000000,2))
				local dm=dg:Select(p,1,1,nil):GetFirst()
				dm:RegisterFlagEffect(FLAG_DECK_MASTER,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_CONTROL,EFFECT_FLAG_CLIENT_HINT,1,nil,aux.Stringid(153000000,1))
			end
		end
	end

	function DeckMaster.loss(e,tp,eg,ep,ev,re,r,rp)
		local dm1=Duel.GetDeckMaster(0)
		local dm2=Duel.GetDeckMaster(1)
		if not dm1 and dm2 then
			Duel.Win(1,WIN_REASON_DECK_MASTER)
		elseif dm1 and not dm2 then
			Duel.Win(0,WIN_REASON_DECK_MASTER)
		elseif not dm1 and not dm2 then
			Duel.Win(PLAYER_NONE,WIN_REASON_DECK_MASTER)
		end
	end

	function DeckMaster.AddProcedure(c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_STARTUP)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_ALL)
		e1:SetCountLimit(1)
		e1:SetOperation(DeckMaster.startProcedure)
		c:RegisterEffect(e1)
	end

	function DeckMaster.startProcedure(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():MoveToDeckMasterZone(tp)
		DeckMaster.RegisterRules()
	end
	function DeckMaster.spcon(e,tp,eg,ep,ev,re,r,rp)
		local dm=DeckMasterZone[tp]
		return dm and dm:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	
	function DeckMaster.spop(e,tp,eg,ep,ev,re,r,rp)
		if not Duel.SelectYesNo(tp,aux.Stringid(153000000,0)) then return end
		DeckMasterZone[tp]:SummonDeckMaster(tp)
	end
end
