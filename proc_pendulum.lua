if not aux.PendulumProcedure then
	aux.PendulumProcedure = {}
	Pendulum = aux.PendulumProcedure
end
if not Pendulum then
	Pendulum = aux.PendulumProcedure
end
--add procedure to Pendulum monster, also allows registeration of activation effect
Pendulum.AddProcedure = aux.FunctionWithNamedArgs(
function(c,reg,desc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	if desc then
		e1:SetDescription(desc)
	else
		e1:SetDescription(1074)
	end
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(Pendulum.Condition())
	e1:SetOperation(Pendulum.Operation())
	e1:SetValue(SUMMON_TYPE_PENDULUM)
	c:RegisterEffect(e1)
	--register by default
	if reg==nil or reg then
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(1160)
		e2:SetType(EFFECT_TYPE_ACTIVATE)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetRange(LOCATION_HAND)
		c:RegisterEffect(e2)
	end
end,"handler","register","desc")
function Pendulum.Filter(c,e,tp,lscale,rscale,lvchk)
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
	else
		lv=c:GetLevel()
	end
	return (c:IsLocation(LOCATION_HAND) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
		and (lvchk or (lv>lscale and lv<rscale) or c:IsHasEffect(511004423)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false)
		and not c:IsForbidden()
end
function Pendulum.Condition()
	return	function(e,c,inchain,re,rp)
				if c==nil then return true end
				local tp=c:GetControler()
				local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				if rpz==nil or c==rpz or (not inchain and Duel.GetFlagEffect(tp,10000000)>0) then return false end
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				local loc=0
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
				if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)>0 then loc=loc+LOCATION_EXTRA end
				if loc==0 then return false end
				local g=nil
				if og then
					g=og:Filter(Card.IsLocation,nil,loc)
				else
					g=Duel.GetFieldGroup(tp,loc,0)
				end
				return g:IsExists(Pendulum.Filter,1,nil,e,tp,lscale,rscale,c:IsHasEffect(511007000) and rpz:IsHasEffect(511007000))
			end
end
function Pendulum.Operation()
	return	function(e,tp,eg,ep,ev,re,r,rp,c,sg,inchain)
				local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
				local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
				local ft=Duel.GetUsableMZoneCount(tp)
				if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
					if ft1>0 then ft1=1 end
					if ft2>0 then ft2=1 end
					ft=1
				end
				local loc=0
				if ft1>0 then loc=loc+LOCATION_HAND end
				if ft2>0 then loc=loc+LOCATION_EXTRA end
				local tg=nil
				if og then
					tg=og:Filter(Card.IsLocation,nil,loc):Match(Pendulum.Filter,nil,e,tp,lscale,rscale,c:IsHasEffect(511007000) and rpz:IsHasEffect(511007000))
				else
					tg=Duel.GetMatchingGroup(Pendulum.Filter,tp,loc,0,nil,e,tp,lscale,rscale,c:IsHasEffect(511007000) and rpz:IsHasEffect(511007000))
				end
				ft1=math.min(ft1,tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND))
				ft2=math.min(ft2,tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA))
				ft2=math.min(ft2,aux.CheckSummonGate(tp) or ft2)
				while true do
					local ct1=tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
					local ct2=tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
					local ct=ft
					if ct1>ft1 then ct=math.min(ct,ft1) end
					if ct2>ft2 then ct=math.min(ct,ft2) end
					local loc=0
					if ft1>0 then loc=loc+LOCATION_HAND end
					if ft2>0 then loc=loc+LOCATION_EXTRA end
					local g=tg:Filter(Card.IsLocation,sg,loc)
					if #g==0 or ft==0 then break end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local tc=Group.SelectUnselect(g,sg,tp,#sg>0,Duel.IsSummonCancelable())
					if not tc then break end
					if sg:IsContains(tc) then
						sg:RemoveCard(tc)
						if tc:IsLocation(LOCATION_HAND) then
							ft1=ft1+1
						else
							ft2=ft2+1
						end
						ft=ft+1
					else
						sg:AddCard(tc)
						if c:IsHasEffect(511007000)~=nil or rpz:IsHasEffect(511007000)~=nil then
							if not Pendulum.Filter(tc,e,tp,lscale,rscale) then
								local pg=sg:Filter(aux.TRUE,tc)
								local ct0,ct3,ct4=#pg,pg:FilterCount(Card.IsLocation,nil,LOCATION_HAND),pg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
								sg:Sub(pg)
								ft1=ft1+ct3
								ft2=ft2+ct4
								ft=ft+ct0
							else
								local pg=sg:Filter(aux.NOT(Pendulum.Filter),nil,e,tp,lscale,rscale)
								sg:Sub(pg)
								if #pg>0 then
									if pg:GetFirst():IsLocation(LOCATION_HAND) then
										ft1=ft1+1
									else
										ft2=ft2+1
									end
									ft=ft+1
								end
							end
						end
						if tc:IsLocation(LOCATION_HAND) then
							ft1=ft1-1
						else
							ft2=ft2-1
						end
						ft=ft-1
					end
				end
				if #sg>0 then
					if not inchain then
						Duel.RegisterFlagEffect(tp,10000000,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
					end
					Duel.HintSelection(Group.FromCards(c),true)
					Duel.HintSelection(Group.FromCards(rpz),true)
				end
			end
end
function Pendulum.RegisterAdditionalPendulumSummon(rc,tp,id,summonfilter,resets,resetcount)
	local CARD_HARMONIC_OSCILATION=31531170
	local CARD_ZEFRAATH=29432356
	summonfilter=summonfilter or aux.TRUE
	resets=resets or (RESET_PHASE|PHASE_END)
	resetcount=resetcount or 1
	
	local function AdditionalPendulumFilter(c,e,tp,lscale,rscale)
		return summonfilter(c,e,tp) and Pendulum.Filter(c,e,tp,lscale,rscale)
	end
	
	local function SelfAdditionalPendulumCond(e,c,og)
		if c==nil then return true end
		local tp=c:GetControler()
		local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		if rpz==nil or c==rpz or Duel.GetFlagEffect(tp,CARD_ZEFRAATH)>0 then return false end
		local lscale=c:GetLeftScale()
		local rscale=rpz:GetRightScale()
		if lscale>rscale then lscale,rscale=rscale,lscale end
		local loc=0
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_HAND end
		if Duel.GetLocationCountFromEx(tp)>0 then loc=loc|LOCATION_EXTRA end
		if loc==0 then return false end
		local g=nil
		if og then
			g=og:Filter(Card.IsLocation,nil,loc)
		else
			g=Duel.GetFieldGroup(tp,loc,0)
		end
		return g:IsExists(AdditionalPendulumFilter,1,nil,e,tp,lscale,rscale)
	end
	
	local function SelfAdditionalPendulumOp(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
		local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		local lscale=c:GetLeftScale()
		local rscale=rpz:GetRightScale()
		if lscale>rscale then lscale,rscale=rscale,lscale end
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local ft2=Duel.GetLocationCountFromEx(tp)
		local ft=Duel.GetUsableMZoneCount(tp)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
			if ft1>0 then ft1=1 end
			if ft2>0 then ft2=1 end
			ft=1
		end
		local loc=0
		if ft1>0 then loc=loc|LOCATION_HAND end
		if ft2>0 then loc=loc|LOCATION_EXTRA end
		local tg=nil
		if og then
			tg=og:Filter(Card.IsLocation,nil,loc):Filter(AdditionalPendulumFilter,nil,e,tp,lscale,rscale)
		else
			tg=Duel.GetMatchingGroup(AdditionalPendulumFilter,tp,loc,0,nil,e,tp,lscale,rscale)
		end
		ft1=math.min(ft1,tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND))
		ft2=math.min(ft2,tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA))
		ft2=math.min(ft2,aux.CheckSummonGate(tp) or ft2)
		while true do
			local ct1=tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
			local ct2=tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
			local ct=ft
			if ct1>ft1 then ct=math.min(ct,ft1) end
			if ct2>ft2 then ct=math.min(ct,ft2) end
			local loc=0
			if ft1>0 then loc=loc|LOCATION_HAND end
			if ft2>0 then loc=loc|LOCATION_EXTRA end
			local g=tg:Filter(Card.IsLocation,sg,loc)
			if #g==0 or ft==0 then break end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc=Group.SelectUnselect(g,sg,tp,true,true)
			if not tc then break end
			if sg:IsContains(tc) then
					sg:RemoveCard(tc)
					if tc:IsLocation(LOCATION_HAND) then
					ft1=ft1+1
				else
					ft2=ft2+1
				end
				ft=ft+1
			else
				sg:AddCard(tc)
				if tc:IsLocation(LOCATION_HAND) then
					ft1=ft1-1
				else
					ft2=ft2-1
				end
				ft=ft-1
			end
		end
		if #sg>0 then
			Duel.Hint(HINT_CARD,0,id)
			Duel.RegisterFlagEffect(tp,CARD_ZEFRAATH,RESET_PHASE|PHASE_END|RESET_SELF_TURN,0,1)
			Duel.HintSelection(Group.FromCards(c))
			Duel.HintSelection(Group.FromCards(rpz))
		end
	end
	
	local function OppoAdditionalPendulumCond(e,c,og)
		if c==nil then return true end
		local tp=e:GetOwnerPlayer()
		local rpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
		if rpz==nil or rpz:GetFieldID()~=c:GetFlagEffectLabel(CARD_HARMONIC_OSCILATION) or Duel.HasFlagEffect(tp,CARD_ZEFRAATH) then return false end
		local lscale=c:GetLeftScale()
		local rscale=rpz:GetRightScale()
		if lscale>rscale then lscale,rscale=rscale,lscale end
		local loc=0
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_HAND end
		if Duel.GetLocationCountFromEx(tp)>0 then loc=loc|LOCATION_EXTRA end
		if loc==0 then return false end
		local g=nil
		if og then
			g=og:Filter(Card.IsLocation,nil,loc)
		else
			g=Duel.GetFieldGroup(tp,loc,0)
		end
		return g:IsExists(AdditionalPendulumFilter,1,nil,e,tp,lscale,rscale)
	end
	
	local function OppoAdditionalPendulumOp(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
		local tp=e:GetOwnerPlayer()
		local rpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
		local lscale=c:GetLeftScale()
		local rscale=rpz:GetRightScale()
		if lscale>rscale then lscale,rscale=rscale,lscale end
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local ft2=Duel.GetLocationCountFromEx(tp)
		local ft=Duel.GetUsableMZoneCount(tp)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
			if ft1>0 then ft1=1 end
			if ft2>0 then ft2=1 end
			ft=1
		end
		local loc=0
		if ft1>0 then loc=loc|LOCATION_HAND end
		if ft2>0 then loc=loc|LOCATION_EXTRA end
		local tg=nil
		if og then
			tg=og:Filter(Card.IsLocation,nil,loc):Filter(AdditionalPendulumFilter,nil,e,tp,lscale,rscale)
		else
			tg=Duel.GetMatchingGroup(AdditionalPendulumFilter,tp,loc,0,nil,e,tp,lscale,rscale)
		end
		ft1=math.min(ft1,tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND))
		ft2=math.min(ft2,tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA))
		ft2=math.min(ft2,aux.CheckSummonGate(tp) or ft2)
		while true do
			local ct1=tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
			local ct2=tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
			local ct=ft
			if ct1>ft1 then ct=math.min(ct,ft1) end
			if ct2>ft2 then ct=math.min(ct,ft2) end
			local loc=0
			if ft1>0 then loc=loc|LOCATION_HAND end
			if ft2>0 then loc=loc|LOCATION_EXTRA end
			local g=tg:Filter(Card.IsLocation,sg,loc)
			if #g==0 or ft==0 then break end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc=Group.SelectUnselect(g,sg,tp,true,true)
			if not tc then break end
			if sg:IsContains(tc) then
					sg:RemoveCard(tc)
					if tc:IsLocation(LOCATION_HAND) then
					ft1=ft1+1
				else
					ft2=ft2+1
				end
				ft=ft+1
			else
				sg:AddCard(tc)
				if tc:IsLocation(LOCATION_HAND) then
					ft1=ft1-1
				else
					ft2=ft2-1
				end
				ft=ft-1
			end
		end
		if #sg>0 then
			Duel.Hint(HINT_CARD,0,id)
			Duel.RegisterFlagEffect(tp,CARD_ZEFRAATH,RESET_PHASE|PHASE_END|RESET_SELF_TURN,0,1)
			Duel.HintSelection(Group.FromCards(c))
			Duel.HintSelection(Group.FromCards(rpz))
		end
	end
	
	local function AdditionPendulumSummonProc()
		local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
		if lpz and not lpz:HasFlagEffect(id) then
			--Provide the effect to the left pendulum scale
			local e1=Effect.CreateEffect(rc)
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SPSUMMON_PROC_G)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(LOCATION_PZONE)
			e1:SetCondition(SelfAdditionalPendulumCond)
			e1:SetOperation(SelfAdditionalPendulumOp)
			e1:SetValue(SUMMON_TYPE_PENDULUM)
			e1:SetReset(RESET_PHASE|PHASE_END)
			lpz:RegisterEffect(e1)
			lpz:RegisterFlagEffect(id,RESET_PHASE|PHASE_END,0,1)
		end
		local opp_lpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,0)
		local opp_rpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
		--For the interaction with "Harmonic Oscilation"
		if opp_lpz and opp_rpz and not opp_lpz:HasFlagEffect(id)
			and opp_lpz:GetFlagEffectLabel(CARD_HARMONIC_OSCILATION)==opp_rpz:GetFieldID()
			and opp_rpz:GetFlagEffectLabel(CARD_HARMONIC_OSCILATION)==opp_lpz:GetFieldID() then
			local e2=Effect.CreateEffect(rc)
			e2:SetDescription(aux.Stringid(id,1))
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_SPSUMMON_PROC_G)
			e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_BOTH_SIDE)
			e2:SetRange(LOCATION_PZONE)
			e2:SetCondition(OppoAdditionalPendulumCond)
			e2:SetOperation(OppoAdditionalPendulumOp)
			e2:SetValue(SUMMON_TYPE_PENDULUM)
			e2:SetReset(RESETS_STANDARD_PHASE_END)
			opp_lpz:RegisterEffect(e2)
			opp_lpz:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
		end
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	--Continuously provide an EFFECT_SPSUMMON_PROC_G to the left Pendulum Zone
	local additionalpeff=Effect.CreateEffect(rc)
	additionalpeff:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	additionalpeff:SetCode(EVENT_ADJUST)
	additionalpeff:SetOperation(AdditionPendulumSummonProc)
	additionalpeff:SetReset(resets,resetcount)
	Duel.RegisterEffect(additionalpeff,tp)
	AdditionPendulumSummonProc()
end
