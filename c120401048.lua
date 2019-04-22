--超量警報アルファンシグナル
--Super Quantal Alphan Signal
--Scripted by Eerie Code
function c120401048.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)	
	e1:SetCountLimit(1,120401048+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c120401048.condition)
	e1:SetTarget(c120401048.target)
	e1:SetOperation(c120401048.activate)
	c:RegisterEffect(e1)
end
function c120401048.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function c120401048.filter(c,e,tp)
	return c:IsSetCard(0xdc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c120401048.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c120401048.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c120401048.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c120401048.filter,tp,LOCATION_DECK,0,nil,e,tp)
	local ft=math.min(Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE),g:GetClassCount(Card.GetCode))
	if ft>0 then
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		local ctn=true
		local sg=Group.CreateGroup()
		while ft>0 and ctn do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc=g:Select(tp,1,1,nil):GetFirst()
			sg:AddCard(tc)
			g:Remove(Card.IsCode,nil,tc:GetCode())
			ft=ft-1
			if ft<=0 or g:GetCount()<=0 or not Duel.SelectYesNo(tp,aux.Stringid(120401048,0)) then ctn=false end
		end
		local fid=c:GetFieldID()
		for tc in aux.Next(sg) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(120401048,RESET_EVENT+0x1fe0000,0,1,fid)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			tc:RegisterEffect(e2)
		end
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE+PHASE_END)
		ge1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		ge1:SetCountLimit(1)
		ge1:SetLabel(fid)
		ge1:SetLabelObject(sg)
		ge1:SetCondition(c120401048.descon)
		ge1:SetOperation(c120401048.desop)
		Duel.RegisterEffect(ge1,tp)
		Duel.SpecialSummonComplete()
	end
	local ge2=Effect.CreateEffect(e:GetHandler())
	ge2:SetType(EFFECT_TYPE_FIELD)
	ge2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ge2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	ge2:SetTargetRange(1,0)
	ge2:SetTarget(c120401048.splimit)
	ge2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ge2,tp)
end
function c120401048.splimit(e,c)
	return not c:IsSetCard(0xdc)
end
function c120401048.desfilter(c,fid)
	return c:GetFlagEffectLabel(120401048)==fid
end
function c120401048.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c120401048.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function c120401048.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c120401048.desfilter,nil,e:GetLabel())
	Duel.Destroy(tg,REASON_EFFECT)
end
