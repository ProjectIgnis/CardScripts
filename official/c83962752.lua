--シンクロ・パニック
--Synchro Panic
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Tuner and any number of non-Tuners from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetCondition(function(e,tp,eg,ep) return tp==ep end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Keep track of the destroyed Synchro Monsters
	aux.GlobalCheck(s,function()
		s.desgroup={}
		s.desgroup[0]=Group.CreateGroup()
		s.desgroup[1]=Group.CreateGroup()
		s.desgroup[0]:KeepAlive()
		s.desgroup[1]:KeepAlive()
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_DESTROYED)
		e0:SetOperation(s.desgroupregop)
		Duel.RegisterEffect(e0,0)
	end)
	--Neither player can Synchro Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetTarget(function(e,c,tp,sumtp,sumpos) return (sumtp&SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO end)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp,e)
	return c:IsType(TYPE_SYNCHRO) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
		and (not e or c:IsCanBeEffectTarget(e))
end
function s.desgroupregop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local tg=eg:Filter(s.cfilter,nil,p)
		if #tg>0 then
			for tc in tg:Iter() do
				tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
			end
			if Duel.GetCurrentChain()==0 then s.desgroup[p]:Clear() end
			s.desgroup[p]:Merge(tg)
			s.desgroup[p]:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
			Duel.RaiseEvent(s.desgroup[p],EVENT_CUSTOM+id,re,r,rp,p,0)
		end
	end
end
function s.spfilter(c,e,tp)
	return c:HasLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.specialcheck(c,sumg,ft)
	return aux.SelectUnselectGroup(sumg,e,tp,2,ft,s.rescon(c:GetLevel(),ft),0)
end
function s.rescon(lvl,ft)
	return function(sg,e,tp,mg)
		return ft>=#sg and sg:FilterCount(Card.IsType,nil,TYPE_TUNER)==1
			and sg:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_TUNER)
			and sg:GetSum(Card.GetLevel)==lvl
		end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local synchg=s.desgroup[tp]:Filter(s.cfilter,nil,tp,e)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local sumg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chkc then return synchg:IsContains(chkc) and aux.SelectUnselectGroup(sumg,e,tp,2,ft,s.rescon(chkc:GetLevel(),ft),0) end
	if chk==0 then return ft>=2 and #sumg>=2 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and synchg:IsExists(s.specialcheck,1,nil,sumg,ft)
	end
	local tc=nil
	if #synchg==1 then
		tc=synchg:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=synchg:FilterSelect(tp,s.specialcheck,1,1,nil,sumg,ft)
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
	local c=e:GetHandler()
	--Destroy this card during your 3rd Standby Phase after activation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e1:SetOperation(s.sdesop)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,3)
	c:RegisterEffect(e1)
	c:SetTurnCounter(0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<2 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if #g<2 then return end
	local lvl=tc:GetLevel()
	local sg=aux.SelectUnselectGroup(g,e,tp,2,math.min(ft,#g),s.rescon(lvl,ft),1,tp,HINTMSG_SPSUMMON,s.rescon(lvl,ft))
	if #sg==0 then return end
	local c=e:GetHandler()
	for tc in sg:Iter() do
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			--Cannot be destroyed by battle or card effects this turn
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3008)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			tc:RegisterEffect(e2,true)
		end
	end
	Duel.SpecialSummonComplete()
end
function s.sdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		Duel.Destroy(c,REASON_RULE)
	end
end