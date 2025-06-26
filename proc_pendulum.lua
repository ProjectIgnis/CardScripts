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
		e1:SetDescription(1163)
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
function Pendulum.PlayerCanGainAdditionalPendulumSummon(player,effect_flag)
	return not (Duel.HasFlagEffect(player,CARD_ZEFRAATH) or Duel.HasFlagEffect(player,effect_flag)) and Duel.IsTurnPlayer(player) and not Duel.IsPhase(PHASE_END)
end
function Pendulum.GrantAdditionalPendulumSummon(handler,pendulum_filter,player,pendulum_location,hint_description,effect_description,owner_card_id,reset,reset_count)
	if not Pendulum.PlayerCanGainAdditionalPendulumSummon(player,owner_card_id) then return end
	reset=reset or RESET_PHASE|PHASE_END
	reset_count=reset_count or 1
	aux.RegisterClientHint(handler,0,player,1,0,hint_description,reset,reset_count)
	local flag_id=owner_card_id==CARD_ZEFRAATH and owner_card_id+1 or owner_card_id
	Duel.RegisterFlagEffect(player,flag_id,reset,0,reset_count)
	---Create an extra Pendulum Summon effect
	local extra_pendulum_effect=Pendulum.CreateAdditionalPendulumSummonEffect(handler,pendulum_filter,pendulum_location,effect_description,owner_card_id,reset,reset_count)
	--Grant the above effect to cards in your Pendulum Zones
	local e1=Effect.CreateEffect(handler)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_PZONE) end)
	e1:SetLabelObject(extra_pendulum_effect)
	e1:SetReset(reset,reset_count)
	Duel.RegisterEffect(e1,player)
	if pendulum_location&LOCATION_EXTRA==0 then return end
	--Create an equivalent effect for "Harmonic Oscillation"
	local harmonic_effect=Pendulum.CreateHarmonicOscillationEffect(handler,pendulum_filter,effect_description,owner_card_id)
	--Grant the above effect to cards in your opponent's Pendulum Zones
	local e2=e1:Clone()
	e2:SetTargetRange(0,LOCATION_SZONE)
	e2:SetLabelObject(harmonic_effect)
	Duel.RegisterEffect(e2,player)
end
function Pendulum.CreateAdditionalPendulumSummonEffect(handler,pendulum_filter,pendulum_location,effect_description,owner_card_id,reset,reset_count)
	pendulum_filter=pendulum_filter or aux.TRUE
	pendulum_location=pendulum_location or LOCATION_HAND|LOCATION_EXTRA
	effect_description=effect_description or 1163
	reset=reset or RESET_PHASE|PHASE_END
	reset_count=reset_count or 1
	
	local function AdditionalPendulumSummonCondition(pendulum_filter,pendulum_location)
		return function(e,c,inchain,re,rp)
			if c==nil then return true end
			if inchain then return false end
			local tp=c:GetControler()
			if Duel.HasFlagEffect(tp,CARD_ZEFRAATH) then return false end
			local available_zones_count=0
			if pendulum_location&LOCATION_HAND>0 then available_zones_count=Duel.GetLocationCount(tp,LOCATION_MZONE) end
			if pendulum_location&LOCATION_EXTRA>0 then available_zones_count=available_zones_count+Duel.GetLocationCountFromEx(tp) end
			if available_zones_count==0 then return false end
			local right_scale_card=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
			if right_scale_card==nil or c==right_scale_card then return false end
			local left_scale=c:GetLeftScale()
			local right_scale=right_scale_card:GetRightScale()
			if left_scale>right_scale then left_scale,right_scale=right_scale,left_scale end
			return Duel.IsExistingMatchingCard(aux.AND(Pendulum.Filter,pendulum_filter),tp,pendulum_location,0,1,nil,e,tp,left_scale,right_scale)
		end
	end
	local function AdditionalPendulumSummonOperation(pendulum_filter,pendulum_location,owner_card_id)
		return function(e,tp,eg,ep,ev,re,r,rp,c,sg,inchain)
			local right_scale_card=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
			local left_scale=c:GetLeftScale()
			local right_scale=right_scale_card:GetRightScale()
			if left_scale>right_scale then left_scale,right_scale=right_scale,left_scale end
			local mmz_count=0
			local emz_count=0
			if pendulum_location&LOCATION_HAND>0 then mmz_count=Duel.GetLocationCount(tp,LOCATION_MZONE) end
			if pendulum_location&LOCATION_EXTRA>0 then emz_count=Duel.GetLocationCountFromEx(tp) end
			local usable_mzone_count=Duel.GetUsableMZoneCount(tp)
			if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
				if mmz_count>0 then mmz_count=1 end
				if emz_count>0 then emz_count=1 end
				usable_mzone_count=1
			end
			local available_summon_group=Duel.GetMatchingGroup(aux.AND(Pendulum.Filter,pendulum_filter),tp,pendulum_location,0,nil,e,tp,left_scale,right_scale)
			mmz_count=math.min(mmz_count,available_summon_group:FilterCount(Card.IsLocation,nil,LOCATION_HAND))
			emz_count=math.min(emz_count,available_summon_group:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA))
			emz_count=math.min(emz_count,aux.CheckSummonGate(tp) or emz_count)
			while true do
				if usable_mzone_count==0 then break end
				local temp_location=0
				if mmz_count>0 then temp_location=temp_location|LOCATION_HAND end
				if emz_count>0 then temp_location=temp_location|LOCATION_EXTRA end
				local remaining_summon_group=available_summon_group:Filter(Card.IsLocation,sg,temp_location)
				if #remaining_summon_group==0 then break end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sc=Group.SelectUnselect(remaining_summon_group,sg,tp,#sg>0,Duel.IsSummonCancelable())
				if not sc then break end
				if sg:IsContains(sc) then
					sg:RemoveCard(sc)
					if sc:IsLocation(LOCATION_HAND) then
						mmz_count=mmz_count+1
					else
						emz_count=emz_count+1
					end
					usable_mzone_count=usable_mzone_count+1
				else
					sg:AddCard(sc)
					if sc:IsLocation(LOCATION_HAND) then
						mmz_count=mmz_count-1
					else
						emz_count=emz_count-1
					end
					usable_mzone_count=usable_mzone_count-1
				end
			end
			if #sg>0 then
				Duel.RegisterFlagEffect(tp,CARD_ZEFRAATH,RESET_PHASE|PHASE_END,0,1)
				Duel.Hint(HINT_CARD,0,owner_card_id)
				Duel.HintSelection(c)
				Duel.HintSelection(right_scale_card)
			end
		end
	end
	
	--This turn, you can conduct 1 Pendulum Summon of a monster(s) in addition to your Pendulum Summon (you can only gain this effect once per turn)
	local e1=Effect.CreateEffect(handler)
	e1:SetDescription(effect_description)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(AdditionalPendulumSummonCondition(pendulum_filter,pendulum_location))
	e1:SetOperation(AdditionalPendulumSummonOperation(pendulum_filter,pendulum_location,owner_card_id))
	e1:SetValue(SUMMON_TYPE_PENDULUM)
	e1:SetReset(reset,reset_count)
	return e1
end
function Pendulum.CreateHarmonicOscillationEffect(handler,pendulum_filter,effect_description,owner_card_id,pendulum_flag)
	pendulum_filter=pendulum_filter or aux.TRUE
	pendulum_flag=pendulum_flag or CARD_ZEFRAATH
	effect_description=effect_description or aux.Stringid(CARD_HARMONIC_OSCILLATION,2)
	
	local function HarmonicOscillationCondition(pendulum_flag,pendulum_filter)
		return function(e,c,inchain,re,rp)
			if c==nil then return true end
			local tp=e:GetOwnerPlayer()
			if Duel.GetLocationCountFromEx(tp)<=0 or (inchain and tp==1-rp) or (not inchain and Duel.HasFlagEffect(tp,pendulum_flag)) or (inchain and pendulum_flag~=10000000) then return false end
			local right_scale_card=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
			if right_scale_card==nil or not c:HasFlagEffect(CARD_HARMONIC_OSCILLATION) or not right_scale_card:HasFlagEffect(CARD_HARMONIC_OSCILLATION)
				or c:GetFlagEffectLabel(CARD_HARMONIC_OSCILLATION)~=right_scale_card:GetFlagEffectLabel(CARD_HARMONIC_OSCILLATION) then return false end
			local left_scale=c:GetLeftScale()
			local right_scale=right_scale_card:GetRightScale()
			if left_scale>right_scale then left_scale,right_scale=right_scale,left_scale end
			return Duel.IsExistingMatchingCard(aux.AND(Pendulum.Filter,pendulum_filter),tp,LOCATION_EXTRA,0,1,nil,e,tp,left_scale,right_scale)
		end
	end
	local function HarmonicOscillationOperation(pendulum_flag,pendulum_filter,owner_card_id)
		return function(e,tp,eg,ep,ev,re,r,rp,c,sg,inchain)
			local tp=e:GetOwnerPlayer()
			local right_scale_card=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
			local left_scale=c:GetLeftScale()
			local right_scale=right_scale_card:GetRightScale()
			if left_scale>right_scale then left_scale,right_scale=right_scale,left_scale end
			local ft=Duel.GetLocationCountFromEx(tp)
			if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
			ft=math.min(ft,aux.CheckSummonGate(tp) or ft)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,aux.AND(Pendulum.Filter,pendulum_filter),tp,LOCATION_EXTRA,0,Duel.IsSummonCancelable() and 0 or 1,ft,nil,e,tp,left_scale,right_scale)
			if g then
				sg:Merge(g)
			end
			if #sg>0 then
				if not inchain then
					Duel.RegisterFlagEffect(tp,pendulum_flag,RESET_PHASE|PHASE_END,0,1)
				end
				if pendulum_flag~=10000000 then
					Duel.Hint(HINT_CARD,0,owner_card_id)
				end
				Duel.Hint(HINT_CARD,0,CARD_HARMONIC_OSCILLATION)
				Duel.HintSelection(c)
				Duel.HintSelection(right_scale_card)
			end
		end
	end
	
	--While both targets are in their Pendulum Zones, you can Pendulum Summon using their Pendulum Scales this turn, but only from the Extra Deck
	local e1=Effect.CreateEffect(handler)
	e1:SetDescription(effect_description)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_BOTH_SIDE)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(HarmonicOscillationCondition(pendulum_flag,pendulum_filter))
	e1:SetOperation(HarmonicOscillationOperation(pendulum_flag,pendulum_filter,owner_card_id))
	e1:SetValue(SUMMON_TYPE_PENDULUM)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	--Reset the above effect if the right Pendulum Scale leaves the field
	local e2=Effect.CreateEffect(handler)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(function() if e1 then e1:Reset() end end)
	e2:SetReset(RESETS_STANDARD_PHASE_END)
	return e1,e2
end