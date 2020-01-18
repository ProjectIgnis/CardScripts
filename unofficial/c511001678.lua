--ワンダブル
--Pooch Party
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		local sg=Group.CreateGroup()
		for i=1,2 do
			local token=Duel.CreateToken(tp,id+1)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			token:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			sg=sg+token
		end
		if Duel.SpecialSummonComplete() then
			sg:KeepAlive()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(sg)
			e1:SetCondition(s.descon)
			e1:SetOperation(s.desop)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	Duel.Destroy(tg,REASON_EFFECT)
end