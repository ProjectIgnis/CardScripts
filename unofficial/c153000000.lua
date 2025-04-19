--Deck Master System
local s,id=GetID()

function s.initial_effect(c)
--  aux.EnableExtraRules(c,s,DeckMaster.RegisterRules)
end

if not DeckMaster then
	DeckMaster={}
	DeckMaster[0]={}
	DeckMaster[1]={}
	DeckMasterZone={}
	FLAG_DECK_MASTER = id

	--function that return the flag that check if a monster is treated as a Deck Master
	function Card.IsDeckMaster(c)
		return c:GetFlagEffect(FLAG_DECK_MASTER)>0
	end
	--function that get the Deck Master of player
	function Duel.GetDeckMaster(p)
		return DeckMasterZone[p] or Duel.GetMatchingGroup(Card.IsDeckMaster,p,LOCATION_MZONE,0,nil):GetFirst()
	end
	--function that return the Deck Master of player
	function Duel.IsDeckMaster(p,code)
		return Duel.GetDeckMaster(p) and Duel.GetDeckMaster(p):IsOriginalCode(code)
	end
	-- function that send a card to the DM zone
	-- add the card to the Skill zone, register the DMzone flag then send the card to limbo
	function Card.MoveToDeckMasterZone(c,p)
		Duel.DisableShuffleCheck()
		Duel.SendtoDeck(c,nil,-2,REASON_RULE)
		Duel.Hint(HINT_SKILL_FLIP,p,c:GetOriginalCode()|(1<<32))
		DeckMasterZone[p]=c
	end
	--function that remove the card from the DM/Skill zone
	function Duel.ClearDeckMasterZone(p)
		local c=DeckMasterZone[p]
		if not c then return end
		Duel.Hint(HINT_SKILL_REMOVE,p,c:GetOriginalCode())
		DeckMasterZone[p]=nil
	end
	--function that summon the monster from the DMzone
	--remove from DMzone, remove the DMzone flag, summon the deck master

--RESET_TOFIELD to handle move between S/T and M (maybe change later?)
--RESET_CONTROL to handle control change which will cause Deck Master no longer Deck Master
--Xyz Material is handled by field check automatically
	function Duel.SummonDeckMaster(p)
		local c=DeckMasterZone[p]
		if not c then return false end
		Duel.ClearDeckMasterZone(p)
		local res=Duel.SpecialSummon(c,0,p,p,false,false,POS_FACEUP)
		c:RegisterFlagEffect(FLAG_DECK_MASTER,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_CONTROL,EFFECT_FLAG_CLIENT_HINT,1,nil,aux.Stringid(FLAG_DECK_MASTER,0))
		return res
	end
	function DeckMaster.RegisterAbilities(c,...)
		local deckMasterEffects={...}
		local e0=Effect.GlobalEffect()
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_ADJUST)
		e0:SetOperation(function(e)
			local id=c:GetOriginalCode()
			if not DeckMaster[c:GetOwner()][id] then
				DeckMaster[c:GetOwner()][id]=true
				for _,eff in ipairs(deckMasterEffects) do
					Duel.RegisterEffect(eff:Clone(),c:GetOwner())
				end
			end
			e:Reset()
		end)
		Duel.RegisterEffect(e0,0)
	end

	function DeckMaster.RegisterRules(c)
		for p=0,1 do
			Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(FLAG_DECK_MASTER,1))
			local dmc=Duel.SelectCardsFromCodes(p,1,1,false,false,table.unpack(DeckMasterTableSelect))
			local dg=Duel.GetMatchingGroup(Card.IsOriginalCode,p,LOCATION_ALL,0,nil,dmc)
			if #dg==3 then
				Duel.Hint(HINT_MESSAGE,p,aux.Stringid(FLAG_DECK_MASTER,2))
				Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(FLAG_DECK_MASTER,4))
				local burn=dg:Select(p,1,1,nil)
				Duel.SendtoDeck(burn,nil,-2,REASON_RULE)
			elseif #dg>0 and Duel.SelectYesNo(p,aux.Stringid(FLAG_DECK_MASTER,3)) then
				Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(FLAG_DECK_MASTER,4))
				local burn=dg:Select(p,1,1,nil)
				Duel.SendtoDeck(burn,nil,-2,REASON_RULE)
			end
			local t=Duel.CreateToken(p,dmc)
			t:MoveToDeckMasterZone(p)
		end
		--Summon Deck Master
		local e1=Effect.CreateEffect(c)
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
	function DeckMaster.spcon(e,tp,eg,ep,ev,re,r,rp)
		local dm=DeckMasterZone[tp]
		return Duel.IsMainPhase() and dm and dm:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	function DeckMaster.spop(e,tp,eg,ep,ev,re,r,rp)
		if not Duel.SelectYesNo(tp,aux.Stringid(FLAG_DECK_MASTER,5)) then return end
		Duel.SummonDeckMaster(tp)
	end
	function DeckMaster.inheritcon1(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(Card.IsDeckMaster,1,nil)
	end
	function DeckMaster.inheritop1(e,tp,eg,ep,ev,re,r,rp)
		local g=eg:Filter(Card.IsDeckMaster,nil)
		for tc in aux.Next(g) do
			if tc:GetReason()&REASON_BATTLE==0 and tc:GetReasonCard() then
				tc:GetReasonCard():RegisterFlagEffect(FLAG_DECK_MASTER,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_CONTROL,EFFECT_FLAG_CLIENT_HINT,1,nil,aux.Stringid(FLAG_DECK_MASTER,0))
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
				Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(FLAG_DECK_MASTER,4))
				local dm=dg:Select(p,1,1,nil):GetFirst()
				dm:RegisterFlagEffect(FLAG_DECK_MASTER,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_CONTROL,EFFECT_FLAG_CLIENT_HINT,1,nil,aux.Stringid(FLAG_DECK_MASTER,0))
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
	DeckMasterTableSelect={153000001,153000002,153000003,153000004,153000005,153000006,153000007,153000008,153000009,153000010,
		153000011,153000012,153000013,153000014,153000015,153000016,153000017}
	DeckMasterTable={153000001,153000002,153000003,153000004,153000005,153000006,153000007,153000008,153000009,153000010,
		153000011,153000012,153000013,153000014,153000015,153000016,153000017,153000018}
end