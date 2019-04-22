--Form of Chaos
--designed by Xeno Disturbia#5235
--scripted by edo9300 & Larry (ritual summon procedure) and Naim (second effect)
function c210777034.initial_effect(c)
	--ritual summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c210777034.target)
	e1:SetOperation(c210777034.activate)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
	--spsummon from hand or gy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(210777034,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c210777034.sptg)
	e2:SetOperation(c210777034.spop)
	c:RegisterEffect(e2)
end
c210777034.listed_names={89631139}
function c210777034.filter(c,e,tp,m1,m2,ft)
	if not c:IsSetCard(0xdd) or (c:GetType()&0x81)~=0x81
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local lv=c:GetLevel()
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	local mg2=m2:Filter(Card.IsCanBeRitualMaterial,c,c)
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,nil)
		mg2=mg2:Filter(c.mat_filter,nil)
	end
	if ft>0 then
		return mg:CheckWithSumGreater(Card.GetRitualLevel,lv,c) or mg2:IsExists(function(c,spc)Duel.SetSelectedCard(c)return mg:CheckWithSumGreater(Card.GetRitualLevel,lv,spc)end,nil,1,c)
	else
		return mg:IsExists(Auxiliary.RPGFilterF,1,nil,tp,mg,c,lv) or mg:Filter(function(c)
																				return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
																				end,nil):IsExists(function(c,spc)
																									return mg2:IsExists(function(c,fc)
																														Duel.SetSelectedCard(Group.FromCards(c,fc))
																														return mg:CheckWithSumGreater(Card.GetRitualLevel,lv,spc)
																														end,1,nil,c)
																									end,1,nil,c)
	end
end
function c210777034.checkvalid(c,rc,tp,sg,mg,mg2,ft)
	local deck = (mg2-sg)<mg2
	if mg2:IsContains(c) and deck then return false end
	local lv=rc:GetLevel()
	local res
	if ft<1 and not sg:IsExists(function(c)
		return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
		end,1,nil) then
		return mg:Filter(function(c)
						return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
						end,nil):IsExists(function(c2)
											Duel.SetSelectedCard(sg+c+c2)
											local res2 = mg:CheckWithSumGreater(Card.GetRitualLevel,lv,rc)
											if not res2 and not deck then
												Duel.SetSelectedCard(sg+c+c2)
												res2=(mg+mg2):CheckWithSumGreater(Card.GetRitualLevel,lv,rc)
											end
											return res2
										end,1,nil)

	else
		Duel.SetSelectedCard(sg+c)
		res=mg:CheckWithSumGreater(Card.GetRitualLevel,lv,rc)
		if not res and not deck and not mg2:IsContains(c) then
			for tc in aux.Next(mg2) do
				Duel.SetSelectedCard(sg+c+tc)
				res=mg:CheckWithSumGreater(Card.GetRitualLevel,lv,rc)
			if res then return res end
			end
		end
	end
	return res
end
function c210777034.exfilter0(c)
	return c:IsCode(89631139) and c:IsLevelAbove(1) and c:IsAbleToGrave()
end
function c210777034.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		local sg=Group.CreateGroup()
		if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 then
			sg=Duel.GetMatchingGroup(c210777034.exfilter0,tp,LOCATION_DECK,0,nil)-mg
		end
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(c210777034.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,mg,sg,ft)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c210777034.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetRitualMaterial(tp)
	local sg=Group.CreateGroup()
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 then 
		sg=Duel.GetMatchingGroup(c210777034.exfilter0,tp,LOCATION_DECK,0,nil)-mg
	end
	local full=mg+sg
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c210777034.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,mg,sg,ft)
	local rc=tg:GetFirst()
	if rc then
	local lv=rc:GetLevel()
		full=full:Filter(Card.IsCanBeRitualMaterial,rc,rc)
		if rc.mat_filter then
			full=full:Filter(rc.mat_filter,nil)
		end
		local mat=Group.CreateGroup()
		while true do
			local cg=full:Filter(c210777034.checkvalid,mat,rc,tp,mat,mg,sg,ft)
			if #cg==0 then break end
			local cancelable=(function()Duel.SetSelectedCard(mat)return Group.CreateGroup():CheckWithSumGreater(Card.GetRitualLevel,lv,rc)end)() and (ft>0 or mat:IsExists(function(c)
																																						return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
																																						end,1,nil))
			local tc=cg:SelectUnselect(mat,tp,cancelable,cancelable,1,1)
			if not tc then break end
			if not mat:IsContains(tc) then
				mat=mat+tc
			else
				mat=mat-tc
			end
		end
		rc:SetMaterial(mat)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
		mat:Sub(mat2)
		Duel.ReleaseRitualMaterial(mat)
		Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		Duel.BreakEffect()
		Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		rc:CompleteProcedure()
	end
end
function c210777034.spfilter(c,e,tp)
	return c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c210777034.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c210777034.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c210777034.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c210777034.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end