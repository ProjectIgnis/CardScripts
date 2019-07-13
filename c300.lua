--Deck Masters Mode
--Scripted by edo9id

--Overwritten functions

-- Card.IsLocation()
-- Duel.IsExistingMatchingCard()
-- Duel.IsExistingTarget()
-- Duel.GetMatchingGroup()
-- Duel.GetFieldGroup()
-- Duel.GetFieldGroupCount()
-- Duel.GetMatchingGroupCount()
-- Duel.GetFirstMatchingCard()
-- Duel.SelectMatchingCard()
-- Duel.GetTargetCount()
-- Duel.SelectTarget()

if not DeckMasters then
	DeckMasters={}

	local isloc=Card.IsLocation
		Card.IsLocation=function(c,loc)
			if (Duel.GetMasterRule()<4 and isloc(c,LOCATION_MZONE) and c:GetSequence()==5) or (Duel.GetMasterRule()>=4 and isloc(c,LOCATION_SZONE) and c:GetSequence()==6) then
				return (loc&0xid+100)==0xid+100
			else
				return isloc(c,loc)
			end
		end
	local dmzonechk=function(c) 
		return (Duel.GetMasterRule()<4 and isloc(c,LOCATION_MZONE) and c:GetSequence()==5) or (Duel.GetMasterRule()>=4 and isloc(c,LOCATION_SZONE) and c:GetSequence()==6)
	end
	local isexist=Duel.IsExistingMatchingCard
		Duel.IsExistingMatchingCard=function(f,tp,int_s,int_o,count,ex,...)
		local arg={...}
		local f1=function(c) return not dmzonechk(c) end
		if f~=nil then
			f1=function(c) return f(c,table.unpack(arg)) and not dmzonechk(c) end
		end
		if arg~=nil then
			return isexist(f1,tp,int_s,int_o,count,ex,table.unpack(arg))
		else
			return isexist(f1,tp,int_s,int_o,count,ex)
		end
	end
	local isexisttg=Duel.IsExistingTarget
		Duel.IsExistingTarget=function(f,tp,int_s,int_o,count,ex,...)
		local arg={...}
		local f1=function(c) return not dmzonechk(c) end
		if f~=nil then
			f1=function(c) return f(c,table.unpack(arg)) and not dmzonechk(c) end
		end
		if arg~=nil then
			return isexist(f1,tp,int_s,int_o,count,ex,table.unpack(arg))
		else
			return isexist(f1,tp,int_s,int_o,count,ex)
		end
	end
	local getmatchg=Duel.GetMatchingGroup
		Duel.GetMatchingGroup=function(f,tp,int_s,int_o,ex,...)
		local arg={...}
		local f1=function(c) return not dmzonechk(c) end
		if f~=nil then
			f1=function(c) return f(c,table.unpack(arg)) and not dmzonechk(c) end
		end
		if arg~=nil then
			return getmatchg(f1,tp,int_s,int_o,ex,table.unpack(arg))
		else
			return getmatchg(f1,tp,int_s,int_o,ex)
		end
	end
	local getfg=Duel.GetFieldGroup
		Duel.GetFieldGroup=function(tp,int_s,int_o)
		return getfg(tp,int_s,int_o):Filter(function(c) return not dmzonechk(c) end,nil)
	end
	local getfgc=Duel.GetFieldGroupCount
		Duel.GetFieldGroupCount=function(tp,int_s,int_o)
		return Duel.GetFieldGroup(tp,int_s,int_o):GetCount()
	end
	local getmatchgc=Duel.GetMatchingGroupCount
		Duel.GetMatchingGroupCount=function(f,tp,int_s,int_o,ex,...)
		local arg={...}
		return Duel.GetMatchingGroup(f,tp,int_s,int_o,ex,arg):GetCount()
	end
	local getfmatch=Duel.GetFirstMatchingCard
		Duel.GetFirstMatchingCard=function(f,tp,int_s,int_o,ex,...)
		local arg={...}
		return Duel.GetMatchingGroup(f,tp,int_s,int_o,ex,arg):GetFirst()
	end
	local selmatchc=Duel.SelectMatchingCard
		Duel.SelectMatchingCard=function(sp,f,tp,int_s,int_o,min,max,ex, ...)
		local arg={...}
		local f1=function(c) return not dmzonechk(c) end
		if f~=nil then
			f1=function(c) return f(c,table.unpack(arg)) and not dmzonechk(c) end
		end
		if arg~=nil then
			return selmatchc(sp,f1,tp,int_s,int_o,min,max,ex,table.unpack(arg))
		else
			return selmatchc(sp,f1,tp,int_s,int_o,min,max,ex)
		end
	end
	local gettgc=Duel.GetTargetCount
		Duel.GetTargetCount=function(f,tp,int_s,int_o,ex,...)
		local arg={...}
		return Duel.GetTarget(f,tp,int_s,int_o,ex,arg):GetCount()
	end
	local seltg=Duel.SelectTarget
		Duel.SelectTarget=function(sp,f,tp,int_s,int_o,min,max,ex, ...)
		local arg={...}
		local f1=function(c) return not dmzonechk(c) end
		if f~=nil then
			f1=function(c) return f(c,table.unpack(arg)) and not dmzonechk(c) end
		end
		if arg~=nil then
			local sel=selmatchc(sp,f1,tp,int_s,int_o,min,max,ex,table.unpack(arg))
			Duel.SetTargetCard(sel)
			return sel
		else
			local sel=selmatchc(sp,f1,tp,int_s,int_o,min,max,ex)
			Duel.SetTargetCard(sel)
			return sel
		end
	end

	--New functions

	-- Card.IsDeckMaster()

	function Card.IsDeckMaster(c,both)
		if both then
			return c:IsLocation(0xid+100) and c:GetFlagEffect(id)>0
		else
			return c:IsLocation(0xid+100) or c:GetFlagEffect(id)>0
		end
	end

	function Duel.CheckDMZone(p)
		if Duel.GetMasterRule()<4 then
			return not Duel.GetFieldCard(p,LOCATION_MZONE,5)
		else
			return not Duel.GetFieldCard(p,LOCATION_SZONE,6)
		end
	end

	function Duel.MoveToDMZone(c,p)
		if Duel.GetMasterRule()<4 then
			Duel.MoveToField(c,p,p,LOCATION_MZONE,POS_FACEUP_ATTACK,true,(1<<5))
		else
			Duel.MoveToField(c,p,p,LOCATION_SZONE,POS_FACEUP_ATTACK,true)
			Duel.MoveSequence(c,6)
		end
	end

	--register
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(DeckMasters.con)
	e1:SetOperation(DeckMasters.op)
	Duel.RegisterEffect(e1,0)
	--Deck Masters Zone implementation
	local e2=Effect.GlobalEffect()
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetTargetRange(0xff,0xff)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLocation,0xid+100))
	Duel.RegisterEffect(e2,0)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	Duel.RegisterEffect(e3,0)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_SUM)
	e4:SetValue(DeckMasters.sumval)
	Duel.RegisterEffect(e4,0)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	Duel.RegisterEffect(e5,0)
	local e6=e2:Clone()
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetValue(DeckMasters.efilter)
	Duel.RegisterEffect(e6,0)
	
	function DeckMasters.sumval(e,c)
		return e:GetHandler():IsDeckMaster(true)
	end
	function DeckMasters.efilter(e,te)
		return te:GetHandler()~=e:GetOwner()
	end
	function DeckMasters.con(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetTurnCount()==1
	end
	function DeckMasters.op(e,tp,eg,ep,ev,re,r,rp)
		local g1=getmatchg(function(c) return c.dm and not c.dm_no_activable end,0,0xff,0,nil)
		local g2=getmatchg(function(c) return c.dm and not c.dm_no_activable end,1,0xff,0,nil)
		--Gets the Deck Master that wil be used as start, player 1 will have dm[0] and player 2 wil have dm[1], if a player doesn't have one, it makes the player select a Deck Master
		local dm = {}
		dm[0]=nil
		dm[1]=nil
		local aaa = {}
		aaa[0]=Group.CreateGroup()
		aaa[1]=Group.CreateGroup()
		for _,i in ipairs(tableDm) do
			aaa[0]:AddCard(Duel.CreateToken(0,i))
			aaa[1]:AddCard(Duel.CreateToken(1,i))
		end
		if #g1>0 then
			if #g1==1 then
				dm[0]=g1:GetFirst()
			else
				dm[0]=g1:RandomSelect(0,1):GetFirst()
			end
		elseif #g1==0 then
			dm[0]=aaa[0]:Select(0,1,1,nil):GetFirst()
		end
		if #g2>0 then
			if #g2==1 then
				dm[1]=g2:GetFirst()
			else
				dm[1]=g2:RandomSelect(1,1):GetFirst()
			end
		elseif #g2==0 then
			dm[1]=aaa[1]:Select(1,1,1,nil):GetFirst()
		end
		--Move the Deck Masters to the field and place them in the appropriate zones and, if any, executes the custom operations, then add the special summon effect
		for i=0,1 do
			Duel.MoveToDMZone(dm[i],dm[i]:GetControler())
			Duel.Hint(HINT_CARD,tp,dm[i]:GetOriginalCode())
			if dm[i].dm_op then
					dm[i].dm_op(dm[i])
			end
				if not dm[i].dm_custom then
				--spsummon
				local e1=Effect.CreateEffect(dm[i])
				e1:SetDescription(aux.Stringid(51100567,1))
				e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
				e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
				e1:SetType(EFFECT_TYPE_IGNITION)
				e1:SetRange(0xff)
				e1:SetTarget(DeckMasters.sptg)
				if dm[i].dm_spsummon_op then
					e1:SetOperation(dm[i].dm_spsummon_op)
				else
					e1:SetOperation(DeckMasters.spop)
				end
				dm[i]:RegisterEffect(e1)
			end
			dm[i]:RegisterFlagEffect(id,0,EFFECT_FLAG_CLIENT_HINT,1,0,63)
			if dm[i]:GetPreviousLocation()==LOCATION_HAND then
					Duel.Draw(i,1,REASON_RULE)
			end
		end
		DeckMasters.VictoryEffects(dm[0])
	end

	function DeckMasters.VictoryEffects(c)
			--Pass ability Material
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_BE_MATERIAL)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
			e2:SetTarget(DeckMasters.pass1)
			Duel.RegisterEffect(e2,0)
			--Pass Ability when leaving field and not used as material
			local e3=e2:Clone()
			e3:SetCode(EVENT_LEAVE_FIELD)
			e3:SetTarget(DeckMasters.pass2)
			Duel.RegisterEffect(e3,0)
			--Lose
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e4:SetCode(EVENT_PHASE+PHASE_DRAW)
			e4:SetCountLimit(1)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e4:SetOperation(DeckMasters.loseop2)
			Duel.RegisterEffect(e4,0)
			local e5=e4:Clone()
			e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
			Duel.RegisterEffect(e5,0)
			local e6=e4:Clone()
			e6:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
			Duel.RegisterEffect(e6,0)
			local e7=e4:Clone()
			e7:SetCode(EVENT_PHASE_START+PHASE_MAIN2)
			Duel.RegisterEffect(e7,0)
			local e8=e4:Clone()
			e8:SetCode(EVENT_PHASE_START+PHASE_END)
			Duel.RegisterEffect(e8,0)
			local e9=e4:Clone()
			e9:SetCode(EVENT_PHASE+PHASE_END)
			Duel.RegisterEffect(e9,0)
			--Register new dm
			local e10=Effect.CreateEffect(c)
			e10:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e10:SetCode(EVENT_SPSUMMON_SUCCESS)
			e10:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e10:SetOperation(DeckMasters.checkop)
			Duel.RegisterEffect(e10,0)
	end

	function DeckMasters.loseop2(e,tp,eg,ep,ev,re,r,rp)
		local WIN_REASON_DM=0x56
		local c1=getmatchgc(Card.IsDeckMaster,tp,0xff,0,nil)
		local c2=getmatchgc(Card.IsDeckMaster,tp,0,0xff,nil)
		local f1=Duel.GetFlagEffect(tp,id+1)+Duel.GetFlagEffect(tp,302)
		local f2=Duel.GetFlagEffect(1-tp,id+1)+Duel.GetFlagEffect(1-tp,302)
		if c1==0 and c2>0 and f1==0 then
			Duel.Win(1-tp,WIN_REASON_DM)
		elseif c1==0 and c2==0 and f2==0 and f1==0  then
			Duel.Win(PLAYER_NONE,WIN_REASON_DM)
		elseif c1>0 and c2==0 and f2==0 then
			Duel.Win(tp,WIN_REASON_DM)  
		end
	end

	function DeckMasters.abcon(c)
		return c:IsDeckMaster()
	end

	function DeckMasters.pass1(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return eg:IsExists(DeckMasters.abcon,1,nil,tp) end
		local g=eg:Filter(DeckMasters.abcon,nil,tp)
		if #g>0 then
			local tc=g:GetFirst()
			while tc do
				if not tc:IsReason(REASON_SPSUMMON) then
					DeckMasters.pass2(e,tp,Group.FromCards(tc),ep,ev,re,r,rp)
				else
					local rc=tc:GetReasonCard()
					rc:RegisterFlagEffect(id,0,EFFECT_FLAG_CLIENT_HINT,1,0,63)
					tc:ResetFlagEffect(id)
				end
				tc=g:GetNext()
			end
		end
	end

	function DeckMasters.abcon2(c)
		if c.dm_custom_pass_ability then
			return c.dm_custom_pass_ability(c)
		else
			return c:IsDeckMaster() and not c:IsReason(REASON_MATERIAL)
		end
	end

	function DeckMasters.pass2(e,tp,eg,ep,ev,re,r,rp)
		if chk==0 then return eg:IsExists(DeckMasters.abcon2,1,nil,tp) end
		local g=eg:Filter(DeckMasters.abcon2,nil,tp)
		if #g>0 then
			local tc=g:GetFirst()
			while tc do
				tc:ResetFlagEffect(id)
				if Duel.GetFlagEffect(tc:GetControler(),id+1)==0 then
					Duel.RegisterFlagEffect(tc:GetControler(),id+1,RESET_PHASE+PHASE_DRAW+PHASE_STANDBY+PHASE_MAIN1+PHASE_BATTLE+PHASE_MAIN2+PHASE_END,0,1)
				end
				if not tc:IsReason(REASON_DESTROY) then
					Duel.RegisterFlagEffect(tc:GetControler(),302,0,0,1)
				else
					Duel.ResetFlagEffect(tc:GetControler(),302)
				end
				tc=g:GetNext()
			end
		end
	end

	function DeckMasters.filterdm(c,tp)
		return c:IsType(TYPE_MONSTER) and c:GetControler()==tp
	end

	function DeckMasters.checkop(e,tp,eg,ep,ev,re,r,rp)
		for i=0,1 do
			if getmatchgc(Card.IsDeckMaster,i,0xff,0,nil)==0 and Duel.GetFlagEffect(i,id+1)>0 then
				local g=eg:Filter(DeckMasters.filterdm,nil,i)
				if #g>0 then
				local tc=g:GetFirst()
					while tc do
						tc:RegisterFlagEffect(id,0,EFFECT_FLAG_CLIENT_HINT,1,0,63)
						tc=g:GetNext()
					end
				end
			end
		end
	end

	function DeckMasters.RemoveDeckMasters(g1)
		local tc=g1:GetFirst()
		while tc do
			local code=tc:GetCode()
			local loc=tc:GetLocation()
			local tp=tc:GetOwner()
			Duel.SendtoDeck(tc,nil,-2,REASON_RULE)
			if loc==LOCATION_HAND then
				Duel.SendtoHand(Duel.CreateToken(tp,code),tc:GetControler(),2,REASON_RULE)
			else
				Duel.SendtoDeck(Duel.CreateToken(tp,code),tc:GetControler(),2,REASON_RULE)
			end
			tc=g1:GetNext()
		end
	end

	function DeckMasters.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,c:GetType(),c:GetAttack(),c:GetDefense(),c:GetLevel(),c:GetRace(),c:GetAttribute()) and e:GetHandler():IsLocation(0xid+100) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	end
	function DeckMasters.spop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.SendtoDeck(c,2,-2,REASON_RULE)
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
			c:RegisterFlagEffect(id,0,EFFECT_FLAG_CLIENT_HINT,1,0,63)
			Duel.ResetFlagEffect(tp,id+1)
		end
	end


	tableDm = {
	511000559,
	511000560,
	511000562,
	511000563,
	511000564,
	511000565,
	511000566,
	511000567,
	511000568,
	511000569,
	511000570,
	511000571,
	511000572,
	511000573,
	511000574,
	511000575,
	}
end