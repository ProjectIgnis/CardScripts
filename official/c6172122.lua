--真紅眼融合
--Red-Eyes Fusion
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(aux.IsMaterialListSetCard,0x3b),nil,s.fextra,nil,nil,s.stage2)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
end
s.listed_names={CARD_REDEYES_B_DRAGON}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0 and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetLabelObject(e)
	e2:SetTarget(s.splimit)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return se~=e:GetLabelObject()
end
--[[
function s.fcheck(tp,sg,fc)
	return sg:IsExists(aux.FilterBoolFunction(Card.IsSetCard,0x3b,fc,SUMMON_TYPE_FUSION,tp),1,nil)
end
]]
function s.fextra(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil),s.fcheck
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(CARD_REDEYES_B_DRAGON)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.fcheck(tp,sg,fc,sumtype,tp)
	return sg:IsExists(s.ffilter,1,nil,fc,sumtype,tp)
end
function s.ffilter(c,fc,sumtype,tp)
	local mat=fc.material
	local set=fc.material_setcode
	local res
	if mat then
		for _,code in ipairs(mat) do
			res=res or (c:IsSummonCode(nil,SUMMON_TYPE_FUSION,PLAYER_NONE,code) and c:IsSetCard(0x3b,fc,sumtype,tp))
		end
	elseif set then
		res=res or (c:IsSetCard(0x3b,fc,sumtype,tp) and aux.IsMaterialListSetCard(fc,0x3b))
	else
		return false
	end
	return res
end