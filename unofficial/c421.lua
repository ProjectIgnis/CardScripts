--Divine Hierarchy Token
--scripted by Larry126
if not DivineHierarchy then
	DivineHierarchy = {}
	local function finish_setup()
		--rank
		local rank=Effect.GlobalEffect()
		rank:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		rank:SetCode(EVENT_ADJUST)
		rank:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_IGNORE_RANGE)
		rank:SetCondition(DivineHierarchy.hrcon)
		rank:SetOperation(DivineHierarchy.rank)
		Duel.RegisterEffect(rank,0) 
		--immunes
		local immunity=Effect.GlobalEffect()
		immunity:SetType(EFFECT_TYPE_FIELD)
		immunity:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		immunity:SetCode(EFFECT_IMMUNE_EFFECT)
		immunity:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		immunity:SetTarget(DivineHierarchy.hrtg)
		immunity:SetValue(DivineHierarchy.hrfilter)
		Duel.RegisterEffect(immunity,0)
		local control=Effect.GlobalEffect()
		control:SetType(EFFECT_TYPE_FIELD)
		control:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		control:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		control:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
		control:SetTarget(DivineHierarchy.control)
		Duel.RegisterEffect(control,0)
		local rel=Effect.GlobalEffect()
		rel:SetType(EFFECT_TYPE_FIELD)
		rel:SetCode(EFFECT_CANNOT_RELEASE)
		rel:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		rel:SetTargetRange(1,1)
		rel:SetTarget(DivineHierarchy.rellimit)
		Duel.RegisterEffect(rel,0)
		--last 1 turn
		local ep=Effect.GlobalEffect()
		ep:SetDescription(aux.Stringid(4011,15))
		ep:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ep:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		ep:SetRange(LOCATION_MZONE)
		ep:SetCode(EVENT_PHASE+PHASE_END)
		ep:SetCondition(DivineHierarchy.stgcon)
		ep:SetOperation(DivineHierarchy.stgop)
		 --release limit
		local r1=Effect.GlobalEffect()
		r1:SetType(EFFECT_TYPE_SINGLE)
		r1:SetCode(EFFECT_UNRELEASABLE_SUM)
		r1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		r1:SetRange(LOCATION_MZONE)
		r1:SetValue(DivineHierarchy.sumlimit)
		--battle
		local dg=r1:Clone()
		dg:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		dg:SetValue(DivineHierarchy.tglimit)
		local bt=dg:Clone()
		bt:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		-- immune to leaving
		local im=Effect.GlobalEffect()
		im:SetCode(EFFECT_SEND_REPLACE)
		im:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		im:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		im:SetRange(LOCATION_MZONE)
		im:SetTarget(DivineHierarchy.reptg)
		im:SetValue(function(e,c) return false end)
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		ge1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		ge1:SetTarget(DivineHierarchy.granttg)
		ge1:SetLabelObject(ep)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetLabelObject(r1)
		Duel.RegisterEffect(ge2,0)
		local ge3=ge1:Clone()
		ge3:SetLabelObject(dg)
		Duel.RegisterEffect(ge3,0)
		local ge4=ge1:Clone()
		ge4:SetLabelObject(bt)
		Duel.RegisterEffect(ge4,0)
		local ge5=ge1:Clone()
		ge5:SetLabelObject(im)
		Duel.RegisterEffect(ge5,0)
	end
	
	function DivineHierarchy.granttg(e,c)
		return c:GetFlagEffect(513000065)>0 and c:IsFaceup()
	end
	function DivineHierarchy.rank1(c)
		local code1,code2=c:GetOriginalCodeRule() 
		return c:GetFlagEffect(513000065)==0
			and (code1==10000000 or code1==10000010 or code1==10000020
			or code1==62180201 or code1==57793869 or code1==21208154
			or code2==10000000 or code2==10000010 or code2==10000020
			or code2==62180201 or code2==57793869 or code2==21208154)
	end
	function DivineHierarchy.rank2(c)
		local code1,code2=c:GetOriginalCodeRule() 
		return code1==10000010 or code1==21208154 or code2==10000010 or code2==21208154
	end
	function DivineHierarchy.hrcon(e,tp,eg,ev,ep,re,r,rp)
		return Duel.IsExistingMatchingCard(DivineHierarchy.rank1,tp,0xff,0xff,1,nil)
	end
	function DivineHierarchy.rank(e,tp,eg,ev,ep,re,r,rp)
		local g=Duel.GetMatchingGroup(DivineHierarchy.rank1,tp,0xff,0xff,nil)
		for c in aux.Next(g) do
			c:RegisterFlagEffect(513000065,0,0,0,1)
		end
		for c in aux.Next(g:Filter(DivineHierarchy.rank2,nil)) do
			c:ResetFlagEffect(513000065)
			c:RegisterFlagEffect(513000065,0,0,0,2)
		end
	end
	function DivineHierarchy.hrtg(e,c)
		return c:GetFlagEffect(513000065)>0 and c:IsFaceup()
	end
	function DivineHierarchy.hrfilter(e,te,c)
		if not te then return false end
		local tc=te:GetOwner()
		return (te:IsActiveType(TYPE_MONSTER) and c~=tc
			and (not tc:GetFlagEffectLabel(513000065) or c:GetFlagEffectLabel(513000065)>tc:GetFlagEffectLabel(513000065)))
			or (te:IsHasCategory(CATEGORY_TOHAND+CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_RELEASE+CATEGORY_TOGRAVE+CATEGORY_FUSION_SUMMON)
			and te:IsActiveType(TYPE_SPELL+TYPE_TRAP))
	end
	function DivineHierarchy.control(e,c)
		return c:GetFlagEffect(513000065)>0 and c:IsFaceup() and not c:IsHasEffect(513000134)
	end
	function DivineHierarchy.rellimit(e,c,tp,sumtp)
		return c:GetFlagEffect(513000065)>0 and c:IsFaceup() and c:IsControler(1-tp)
	end
	function DivineHierarchy.sumlimit(e,c)
		if not c then return false end
		return e:GetHandler():GetFlagEffect(513000065)>0 and e:GetHandler():IsFaceup() and not c:IsControler(e:GetHandlerPlayer())
	end
	function DivineHierarchy.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return c:IsReason(REASON_EFFECT) and r&REASON_EFFECT~=0 and re and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
			and c:GetFlagEffect(513000065)>0 end
		return true
	end
	function DivineHierarchy.tglimit(e,c)
		return c:GetFlagEffectLabel(513000065)
			and e:GetHandler():GetFlagEffectLabel(513000065)>c:GetFlagEffectLabel(513000065) or false
	end
	function DivineHierarchy.stgcon(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local owner=false
		local effs={c:GetCardEffect()}
		for _,eff in ipairs(effs) do
			owner=(eff:GetOwner()~=c and not eff:GetOwner():IsCode(0)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)))
				and (eff:GetOwner()~=c and not eff:GetOwner():IsCode(0)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)))
				or owner
		end
		return c:GetFlagEffect(513000065)>0 and (owner or c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:GetPreviousLocation()~=0)
	end
	function DivineHierarchy.stgop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local effs={c:GetCardEffect()}
		for _,eff in ipairs(effs) do
			if eff:GetOwner()~=c and not eff:GetOwner():IsCode(0)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)) then
				eff:Reset()
			end
		end
		if c:IsSummonType(SUMMON_TYPE_SPECIAL) then
			if c:IsPreviousLocation(LOCATION_GRAVE) then
				Duel.SendtoGrave(c,REASON_RULE,c:GetPreviousControler())
			elseif c:IsPreviousLocation(LOCATION_DECK) then
				Duel.SendtoDeck(c,c:GetPreviousControler(),2,REASON_RULE)
			elseif c:IsPreviousLocation(LOCATION_HAND) then
				Duel.SendtoHand(c,c:GetPreviousControler(),REASON_RULE)
			elseif c:IsPreviousLocation(LOCATION_REMOVED) then
				Duel.Remove(c,c:GetPreviousPosition(),REASON_RULE,c:GetPreviousControler())
			end
		end
	end
	finish_setup()
end