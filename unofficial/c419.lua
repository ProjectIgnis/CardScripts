--Generate Effect
if not GenerateEffect then
	GenerateEffect={}
	local function finish_setup()
		local e5=Effect.GlobalEffect()
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_ADJUST)
		e5:SetOperation(GenerateEffect.op5)
		Duel.RegisterEffect(e5,0)
		local atkeff=Effect.GlobalEffect()
		atkeff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		atkeff:SetCode(EVENT_CHAIN_SOLVED)
		atkeff:SetOperation(GenerateEffect.atkraiseeff)
		Duel.RegisterEffect(atkeff,0)
		local atkadj=Effect.GlobalEffect()
		atkadj:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		atkadj:SetCode(EVENT_ADJUST)
		atkadj:SetOperation(GenerateEffect.atkraiseadj)
		Duel.RegisterEffect(atkadj,0)
		
		--Armor Monsters
		local arm1=Effect.GlobalEffect()
		arm1:SetType(EFFECT_TYPE_FIELD)
		arm1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		arm1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		arm1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		arm1:SetCondition(GenerateEffect.armatkcon)
		arm1:SetTarget(GenerateEffect.armatktg)
		Duel.RegisterEffect(arm1,0)
		local arm2=Effect.GlobalEffect()
		arm2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		arm2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		arm2:SetCode(EVENT_ATTACK_ANNOUNCE)
		arm2:SetOperation(GenerateEffect.armcheckop)
		arm2:SetLabelObject(arm1)
		Duel.RegisterEffect(arm2,0)
		local arm3=Effect.GlobalEffect()
		arm3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		arm3:SetCode(EVENT_BE_BATTLE_TARGET)
		arm3:SetCondition(GenerateEffect.armatcon)
		arm3:SetOperation(GenerateEffect.armatop)
		Duel.RegisterEffect(arm3,0)
		local arm4=arm3:Clone()
		Duel.RegisterEffect(arm4,1)
		
		--Ignore Indestructability
		local indes=Effect.GlobalEffect()
		indes:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		indes:SetCode(EVENT_DAMAGE_CALCULATING)
		indes:SetOperation(GenerateEffect.batregop)
		Duel.RegisterEffect(indes,0)
		local indes2=Effect.GlobalEffect()
		indes2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		indes2:SetCode(EVENT_BATTLED)
		indes2:SetOperation(GenerateEffect.batend)
		Duel.RegisterEffect(indes2,0)
		IndesTable={}
		
		--Relay Soul/Zero Gate
		local rs1=Effect.GlobalEffect()
		rs1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		rs1:SetCode(EVENT_ADJUST)
		rs1:SetOperation(GenerateEffect.relayop)
		Duel.RegisterEffect(rs1,0)
		local rs2=rs1:Clone()
		rs2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		rs2:SetCode(EVENT_CHAIN_SOLVED)
		Duel.RegisterEffect(rs2,0)
		local rs3=rs2:Clone()
		rs3:SetCode(EVENT_DAMAGE)
		Duel.RegisterEffect(rs3,0)
	end
	
	--Anime card constants
	TYPE_ARMOR		=	0x10000000
	TYPE_PLUS		=	0x20000000
	TYPE_MINUS		=	0x40000000
	
	RACE_YOKAI		=	0x80000000
	RACE_CHARISMA	=	0x100000000
	
	ATTRIBUTE_LAUGH	=	0x80
	
	function GenerateEffect.op5(e,tp,eg,ep,ev,re,r,rp)
		--ATK = 285, prev ATK = 284
		--LVL = 585, prev LVL = 584
		--DEF = 385, prev DEF = 384
		local c=e:GetHandler()
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0xff,0xff,nil)
		if not g then return end
		local tc=g:GetFirst()
		while tc do
			if tc:GetFlagEffect(285)==0 and tc:GetFlagEffect(585)==0 then
				local atk=tc:GetAttack()
				local def=tc:GetDefense()
				if atk<0 then atk=0 end
				if def<0 then def=0 end
				tc:RegisterFlagEffect(285,nil,0,1,atk)
				tc:RegisterFlagEffect(284,nil,0,1,atk)
				tc:RegisterFlagEffect(385,nil,0,1,def)
				tc:RegisterFlagEffect(384,nil,0,1,def)
				local lv=tc:GetLevel()
				tc:RegisterFlagEffect(585,nil,0,1,lv)
				tc:RegisterFlagEffect(584,nil,0,1,lv)
			end	
			tc=g:GetNext()
		end
	end
	function GenerateEffect.atkcfilter(c)
		if c:GetFlagEffect(285)==0 then return false end
		return c:GetAttack()~=c:GetFlagEffectLabel(285)
	end
	function GenerateEffect.defcfilter(c)
		if c:GetFlagEffect(385)==0 then return false end
		return c:GetDefense()~=c:GetFlagEffectLabel(385)
	end
	function GenerateEffect.lvcfilter(c)
		if c:GetFlagEffect(585)==0 then return false end
		return c:GetLevel()~=c:GetFlagEffectLabel(585)
	end
	function GenerateEffect.atkraiseeff(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(GenerateEffect.atkcfilter,tp,0x7f,0x7f,nil)
		local g1=Group.CreateGroup() --change atk
		local g2=Group.CreateGroup() --gain atk
		local g3=Group.CreateGroup() --lose atk
		local g4=Group.CreateGroup() --gain atk from original
		local g9=Group.CreateGroup() --lose atk from original
		
		local dg=Duel.GetMatchingGroup(GenerateEffect.defcfilter,tp,0x7f,0x7f,nil)
		local g5=Group.CreateGroup() --change def
		local g6=Group.CreateGroup() --gain def
		--local g7=Group.CreateGroup() --lose def
		--local g8=Group.CreateGroup() --gain def from original
		local tc=g:GetFirst()
		while tc do
			local prevatk=0
			if tc:GetFlagEffect(285)>0 then prevatk=tc:GetFlagEffectLabel(285) end
			g1:AddCard(tc)
			if prevatk>tc:GetAttack() then
				g3:AddCard(tc)
			else
				g2:AddCard(tc)
				if prevatk<=tc:GetBaseAttack() and tc:GetAttack()>tc:GetBaseAttack() then
					g4:AddCard(tc)
				end
				if prevatk>=tc:GetBaseAttack() and tc:GetAttack()<tc:GetBaseAttack() then
					g9:AddCard(tc)
				end
			end
			tc:ResetFlagEffect(284)
			tc:ResetFlagEffect(285)
			if prevatk>0 then
				tc:RegisterFlagEffect(284,nil,0,1,prevatk)
			else
				tc:RegisterFlagEffect(284,nil,0,1,0)
			end
			if tc:GetAttack()>0 then
				tc:RegisterFlagEffect(285,nil,0,1,tc:GetAttack())
			else
				tc:RegisterFlagEffect(285,nil,0,1,0)
			end
			tc=g:GetNext()
		end
		
		local dc=dg:GetFirst()
		while dc do
			local prevdef=0
			if dc:GetFlagEffect(385)>0 then prevdef=dc:GetFlagEffectLabel(385) end
			g5:AddCard(dc)
			if prevdef>dc:GetDefense() then
				--g7:AddCard(dc)
			else
				g6:AddCard(dc)
				if prevdef<=dc:GetBaseDefense() and dc:GetDefense()>dc:GetBaseDefense() then
					--g8:AddCard(dc)
				end
			end
			dc:ResetFlagEffect(384)
			dc:ResetFlagEffect(385)
			if prevdef>0 then
				dc:RegisterFlagEffect(384,nil,0,1,prevdef)
			else
				dc:RegisterFlagEffect(384,nil,0,1,0)
			end
			if dc:GetDefense()>0 then
				dc:RegisterFlagEffect(385,nil,0,1,dc:GetDefense())
			else
				dc:RegisterFlagEffect(385,nil,0,1,0)
			end
			dc=dg:GetNext()
		end
		
		Duel.RaiseEvent(g1,511001265,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g1,511001441,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g2,511000377,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g2,511001762,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g3,511000883,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g3,511009110,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g4,511002546,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g5,511009053,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g5,511009565,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g9,511010103,re,REASON_EFFECT,rp,ep,0)
		--Duel.RaiseEvent(g6,,re,REASON_EFFECT,rp,ep,0)
		
		local lvg=Duel.GetMatchingGroup(GenerateEffect.lvcfilter,tp,0x7f,0x7f,nil)
		local lvc=lvg:GetFirst()
		while lvc do
			local prevlv=lvc:GetFlagEffectLabel(585)
			lvc:ResetFlagEffect(584)
			lvc:ResetFlagEffect(585)
			lvc:RegisterFlagEffect(584,nil,0,1,prevlv)
			lvc:RegisterFlagEffect(585,nil,0,1,lvc:GetLevel())
			lvc=lvg:GetNext()
		end
		Duel.RaiseEvent(lvg,511002524,re,REASON_EFFECT,rp,ep,0)
		
		Duel.RegisterFlagEffect(tp,285,RESET_CHAIN,0,1)
		Duel.RegisterFlagEffect(1-tp,285,RESET_CHAIN,0,1)
	end
	function GenerateEffect.atkraiseadj(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetFlagEffect(tp,285)~=0 or Duel.GetFlagEffect(1-tp,285)~=0 then return end
		local g=Duel.GetMatchingGroup(GenerateEffect.atkcfilter,tp,0x7f,0x7f,nil)
		local g1=Group.CreateGroup() --change atk
		local g2=Group.CreateGroup() --gain atk
		local g3=Group.CreateGroup() --lose atk
		local g4=Group.CreateGroup() --gain atk from original
		local g9=Group.CreateGroup() --lose atk from original
		
		local dg=Duel.GetMatchingGroup(GenerateEffect.defcfilter,tp,0x7f,0x7f,nil)
		local g5=Group.CreateGroup() --change def
		--local g6=Group.CreateGroup() --gain def
		--local g7=Group.CreateGroup() --lose def
		--local g8=Group.CreateGroup() --gain def from original
		local tc=g:GetFirst()
		while tc do
			local prevatk=0
			if tc:GetFlagEffect(285)>0 then prevatk=tc:GetFlagEffectLabel(285) end
			g1:AddCard(tc)
			if prevatk>tc:GetAttack() then
				g3:AddCard(tc)
			else
				g2:AddCard(tc)
				if prevatk<=tc:GetBaseAttack() and tc:GetAttack()>tc:GetBaseAttack() then
					g4:AddCard(tc)
				end
				if prevatk>=tc:GetBaseAttack() and tc:GetAttack()<tc:GetBaseAttack() then
					g9:AddCard(tc)
				end
			end
			tc:ResetFlagEffect(284)
			tc:ResetFlagEffect(285)
			if prevatk>0 then
				tc:RegisterFlagEffect(284,nil,0,1,prevatk)
			else
				tc:RegisterFlagEffect(284,nil,0,1,0)
			end
			if tc:GetAttack()>0 then
				tc:RegisterFlagEffect(285,nil,0,1,tc:GetAttack())
			else
				tc:RegisterFlagEffect(285,nil,0,1,0)
			end
			tc=g:GetNext()
		end
		
		local dc=dg:GetFirst()
		while dc do
			local prevdef=0
			if dc:GetFlagEffect(385)>0 then prevdef=dc:GetFlagEffectLabel(385) end
			g5:AddCard(dc)
			if prevdef>dc:GetDefense() then
				--g7:AddCard(dc)
			else
				--g6:AddCard(dc)
				if prevdef<=dc:GetBaseDefense() and dc:GetDefense()>dc:GetBaseDefense() then
					--g8:AddCard(dc)
				end
			end
			dc:ResetFlagEffect(284)
			dc:ResetFlagEffect(285)
			if prevdef>0 then
				dc:RegisterFlagEffect(284,nil,0,1,prevdef)
			else
				dc:RegisterFlagEffect(284,nil,0,1,0)
			end
			if dc:GetAttack()>0 then
				dc:RegisterFlagEffect(285,nil,0,1,dc:GetAttack())
			else
				dc:RegisterFlagEffect(285,nil,0,1,0)
			end
			dc=dg:GetNext()
		end
		
		Duel.RaiseEvent(g1,511001265,e,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g2,511001762,e,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g3,511009110,e,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g4,511002546,e,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g5,511009053,e,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g9,511010103,e,REASON_EFFECT,rp,ep,0)
		
		local lvg=Duel.GetMatchingGroup(GenerateEffect.lvcfilter,tp,0x7f,0x7f,nil)
		local lvc=lvg:GetFirst()
		while lvc do
			local prevlv=lvc:GetFlagEffectLabel(585)
			lvc:ResetFlagEffect(584)
			lvc:ResetFlagEffect(585)
			lvc:RegisterFlagEffect(584,nil,0,1,prevlv)
			lvc:RegisterFlagEffect(585,nil,0,1,lvc:GetLevel())
			lvc=lvg:GetNext()
		end
		Duel.RaiseEvent(lvg,511002524,e,REASON_EFFECT,rp,ep,0)
	end
	
	Cardian={}
	function Cardian.check(c,tp,eg,ep,ev,re,r,rp)
		if c:IsSetCard(0xe6) and c:IsType(TYPE_MONSTER) then
			local eff={c:GetCardEffect(511001692)}
			for _,te2 in ipairs(eff) do
				local te=te2:GetLabelObject()
				local con=te:GetCondition()
				local cost=te:GetCost()
				local tg=te:GetTarget()
				if te:GetType()==EFFECT_TYPE_FIELD then
					if not con or con(te,c) then
						return true
					end
				else
					if (not con or con(te,tp,eg,ep,ev,re,r,rp)) and (not cost or cost(te,tp,eg,ep,ev,re,r,rp,0) 
						and (not tg or tg(te,tp,eg,ep,ev,re,r,rp,0))) then
						return true
					end
				end
			end
		end
		return false
	end

	function GenerateEffect.armatkcon(e)
		return Duel.GetFlagEffect(e:GetHandlerPlayer(),110000103)~=0 and Duel.GetFlagEffect(1-e:GetHandlerPlayer(),110000103)~=0
	end
	function GenerateEffect.armatktg(e,c)
		return c:GetFieldID()~=e:GetLabel() and c:IsType(TYPE_ARMOR)
	end
	function GenerateEffect.armcheckop(e,tp,eg,ep,ev,re,r,rp)
		local a=Duel.GetAttacker()
		if not a:IsType(TYPE_ARMOR) then return end
		if Duel.GetFlagEffect(tp,110000103)~=0 and Duel.GetFlagEffect(1-tp,110000103)~=0 then return end
		local fid=eg:GetFirst():GetFieldID()
		Duel.RegisterFlagEffect(tp,110000103,RESET_PHASE+PHASE_END,0,1)
		Duel.RegisterFlagEffect(1-tp,110000103,RESET_PHASE+PHASE_END,0,1)
		e:GetLabelObject():SetLabel(fid)
	end
	function GenerateEffect.armatcon(e,tp,eg,ep,ev,re,r,rp)
		local at=Duel.GetAttackTarget()
		return at:IsFaceup() and at:IsControler(tp) and at:IsType(TYPE_ARMOR)
	end
	function GenerateEffect.armfilter(c)
		return c:IsFaceup() and c:IsType(TYPE_ARMOR)
	end
	function GenerateEffect.armatop(e,tp,eg,ep,ev,re,r,rp)
		local atg=Duel.GetAttacker():GetAttackableTarget()
		local d=Duel.GetAttackTarget()
		if atg:IsExists(GenerateEffect.armfilter,1,d) and Duel.SelectYesNo(tp,aux.Stringid(21558682,0)) then
			local g=atg:FilterSelect(tp,GenerateEffect.armfilter,1,1,d)
			Duel.HintSelection(g)
			Duel.ChangeAttackTarget(g:GetFirst())
		end
	end

	function GenerateEffect.batregop(e,tp,eg,ep,ev,re,r,rp)
		IndesTable={}
		local a=Duel.GetAttacker()
		local d=Duel.GetAttackTarget()
		if a then
			local aex={a:GetCardEffect(511010508)}
			local aei={a:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE),a:GetCardEffect(EFFECT_INDESTRUCTABLE_COUNT),a:GetCardEffect(EFFECT_DESTROY_REPLACE)}
			for _,te in ipairs(aei) do
				for _,ce in ipairs(aex) do
					local val=ce:GetValue()
					if type(val)~='function' or val(ce,te) then
						if not IndesTable[te] then
							table.insert(IndesTable,te)
							IndesTable[te]=te:GetCondition()
							te:SetCondition(aux.FALSE)
						end
						break
					end
				end
			end
		end
		if d then
			local check=false
			local dex={d:GetCardEffect(511010508)}
			local dei={d:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE),d:GetCardEffect(EFFECT_INDESTRUCTABLE_COUNT),d:GetCardEffect(EFFECT_DESTROY_REPLACE)}
			for _,te in ipairs(dei) do
				for _,ce in ipairs(dex) do
					local val=ce:GetValue()
					if type(val)~='function' or val(ce,te) then
						if not IndesTable[te] then
							table.insert(IndesTable,te)
							IndesTable[te]=te:GetCondition()
							te:SetCondition(aux.FALSE)
						end
						break
					end
				end
			end
		end
	end
	function GenerateEffect.batend(e,tp,eg,ep,ev,re,r,rp)
		for _,te in ipairs(IndesTable) do
			if te then
				local con=IndesTable[te]
				if con then
					te:SetCondition(con)
				else
					te:SetCondition(aux.TRUE)
				end
			end
		end
		IndesTable={}
	end

	function GenerateEffect.relayop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if Duel.GetLP(0)<=0 and not Duel.IsPlayerAffectedByEffect(0,EFFECT_CANNOT_LOSE_LP) and Duel.GetFlagEffect(0,511002521)==0 
			and Duel.IsPlayerAffectedByEffect(0,511000793) then
			local ge1=Effect.GlobalEffect()
			ge1:SetType(EFFECT_TYPE_FIELD)
			ge1:SetCode(EFFECT_CANNOT_LOSE_LP)
			ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			ge1:SetTargetRange(1,0)
			Duel.RegisterEffect(ge1,0)
			local ge2=Effect.GlobalEffect()
			ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			ge2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
			ge2:SetCode(EVENT_ADJUST)
			ge2:SetLabelObject(ge1)
			ge2:SetLabel(0)
			ge2:SetOperation(GenerateEffect.relayresetop)
			Duel.RegisterEffect(ge2,0)
			Duel.RaiseEvent(Duel.GetMatchingGroup(aux.TRUE,0,0xff,0,nil),511002521,nil,0,0,0,0)
			Duel.RegisterFlagEffect(0,511002521,0,0,1)
		end
		if Duel.GetLP(1)<=0 and not Duel.IsPlayerAffectedByEffect(1,EFFECT_CANNOT_LOSE_LP) and Duel.GetFlagEffect(1,511002521)==0 
			and Duel.IsPlayerAffectedByEffect(1,511000793) then
			local ge1=Effect.GlobalEffect()
			ge1:SetType(EFFECT_TYPE_FIELD)
			ge1:SetCode(EFFECT_CANNOT_LOSE_LP)
			ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			ge1:SetTargetRange(1,0)
			Duel.RegisterEffect(ge1,1)
			local ge2=Effect.GlobalEffect()
			ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			ge2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
			ge2:SetCode(EVENT_ADJUST)
			ge2:SetLabelObject(ge1)
			ge2:SetLabel(0)
			ge2:SetOperation(GenerateEffect.relayresetop)
			Duel.RegisterEffect(ge2,1)
			Duel.RaiseEvent(Duel.GetMatchingGroup(aux.TRUE,0,0xff,0,nil),511002521,nil,0,0,1,0)
			Duel.RegisterFlagEffect(1,511002521,0,0,1)
		end
	end
	function GenerateEffect.relayresetop(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetCurrentChain()==0 or e:GetLabel()>0 then
			local ct=e:GetLabel()+1
			e:SetLabel(ct)
		end
		if (e:GetLabel()==2 and Duel.GetCurrentPhase()&PHASE_DAMAGE==0) or e:GetLabel()==3 then
			e:GetLabelObject():Reset()
			e:Reset()
			Duel.ResetFlagEffect(tp,511002521)
		end
	end
	
	finish_setup()
end