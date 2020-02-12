if not aux.FusionProcedure then
	aux.FusionProcedure = {}
	Fusion = aux.FusionProcedure
end
if not Fusion then
	Fusion = aux.FusionProcedure
end

function Fusion.ParseMaterialTable(tab,mat)
	local named_mats={}
	local tmp_extramat_func=function(c,fc,sub,sub2,mg,sg,tp,contact,sumtype) return (sub2 and c:IsHasEffect(511002961)) end
	local name_func=function(tab) return function(c,fc,sub,sub2,mg,sg,tp,contact,sumtype) return c:IsSummonCode(fc,sumtype,fc:GetControler(),table.unpack(tab)) or (sub and c:CheckFusionSubstitute(fc)) or (sub2 and c:IsHasEffect(511002961)) end end
	local func=aux.FALSE
	for _,fmat in ipairs(tab) do
		if type(fmat)=="function" then
			func=aux.OR(func,aux.OR(fmat,tmp_extramat_func))
		else
			table.insert(named_mats,fmat)
			local addmat=true
			for index,value in ipairs(mat) do
				if value==fmat then
					addmat=false
				end
			end
			if addmat then table.insert(mat,fmat) end
		end
	end
	func=aux.AND(func,function(c) return not c:IsHasEffect(6205579) end)
	if #named_mats>0 then
		func=aux.OR(func,name_func(named_mats))
	end
	return func
end

--material_count: number of different names in material list
--material: names in material list
--Fusion monster, mixed materials
function Fusion.AddProcMix(c,sub,insf,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local val={...}
	local fun={}
	local mat={}
	for i=1,#val do
		if type(val[i])=='function' then
			fun[i]=function(c,fc,sub,sub2,mg,sg,tp,contact,sumtype) return (val[i](c,fc,sumtype,tp,sub,mg,sg,contact) or (sub2 and c:IsHasEffect(511002961))) and not c:IsHasEffect(6205579) end
		elseif type(val[i])=='table' then
			fun[i]=Fusion.ParseMaterialTable(val[i],mat)
		else
			local addmat=true
			fun[i]=function(c,fc,sub,sub2,mg,sg,tp,contact,sumtype) return c:IsSummonCode(fc,sumtype,fc:GetControler(),val[i]) or (sub and c:CheckFusionSubstitute(fc)) or (sub2 and c:IsHasEffect(511002961)) end
			for index, value in ipairs(mat) do
				if value==val[i] then
					addmat=false
				end
			end
			if addmat then table.insert(mat,val[i]) end
		end
	end
	if c.material_count==nil then
		local mt=c:GetMetatable()
		if #mat>0 then
			mt.material_count=#mat
			mt.material=mat
		end
		--for cards that check number of required materials (Ultra Poly/ Ancient Gear Chaos Fusion)
		mt.min_material_count=#val
		mt.max_material_count=#val
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Fusion.ConditionMix(insf,sub,table.unpack(fun)))
	e1:SetOperation(Fusion.OperationMix(insf,sub,table.unpack(fun)))
	c:RegisterEffect(e1)
	return {e1}
end
function Fusion.ConditionMix(insf,sub,...)
	--g:Material group(nil for Instant Fusion)
	--gc:Material already used
	--chkf: check field, default:PLAYER_NONE
	local funs={...}
	return	function(e,g,gc,chkfnf)
				local mustg=nil
				if g==nil then
					mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,nil,REASON_FUSION)
				return insf and #mustg==0 end
				local chkf=chkfnf&0xff
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
				local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
				local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
				local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
				if notfusion then
					sumtype=0
				elseif contact then
					sumtype=MATERIAL_FUSION
				end
				local matcheck=e:GetValue()
				local sub=not listedmats and (sub or notfusion) and not contact
				local mg=g:Filter(Fusion.ConditionFilterMix,c,c,sub,sub,contact,sumtype,matcheck,tp,table.unpack(funs))
				mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_FUSION)
				if contact then mustg:Clear() end
				if not mg:Includes(mustg) or mustg:IsExists(aux.NOT(Card.IsCanBeFusionMaterial),1,nil,c) then return false end
				if gc then
					if gc:IsExists(aux.NOT(Card.IsCanBeFusionMaterial),1,nil,c) 
						or gc:IsExists(aux.NOT(Fusion.ConditionFilterMix),1,nil,c,sub,sub,contact,sumtype,matcheck,tp,table.unpack(funs)) then return false end
					mustg:Merge(gc)
				end
				local sg=Group.CreateGroup()
				mg:Merge(mustg)
				return mg:IsExists(Fusion.SelectMix,1,nil,tp,mg,sg,mustg,c,sub,sub,contact,sumtype,chkf,table.unpack(funs))
			end
end
function Fusion.OperationMix(insf,sub,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local chkf=chkfnf&0xff
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
				local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
				local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
				local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
				if notfusion then
					sumtype=0
				elseif contact then
					sumtype=MATERIAL_FUSION
				end
				local matcheck=e:GetValue()
				local sub=not listedmats and (sub or notfusion) and not contact
				local mg=eg:Filter(Fusion.ConditionFilterMix,c,c,sub,sub,contact,sumtype,matcheck,tp,table.unpack(funs))
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,eg,tp,c,mg,REASON_FUSION)
				if contact then mustg:Clear() end
				local sg=Group.CreateGroup()
				if gc then
					mustg:Merge(gc)
				end
				for tc in aux.Next(mustg) do
					sg:AddCard(tc)
					if not contact and tc:IsHasEffect(EFFECT_FUSION_MAT_RESTRICTION) then
						local eff={gc:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
						for i=1,#eff do
							local f=eff[i]:GetValue()
							mg=mg:Filter(Auxiliary.HarmonizingMagFilter,tc,eff[i],f)
						end
					end
				end
				local p=tp
				local sfhchk=false
				if not contact and Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					p=1-tp Duel.ConfirmCards(1-tp,mg)
					if mg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				end
				while #sg<#funs do
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
					local tc=Group.SelectUnselect(mg:Filter(Fusion.SelectMix,sg,tp,mg,sg,mustg:Filter(aux.TRUE,sg),c,sub,sub,contact,sumtype,chkf,table.unpack(funs)),sg,p,false,contact and #sg==0,#funs,#funs)
					if not tc then break end
					if #mustg==0 or not mustg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
						else
							sg:RemoveCard(tc)
						end
					end
				end
				if sfhchk then Duel.ShuffleHand(tp) end
				Duel.SetFusionMaterial(sg)
			end
end
function Fusion.ConditionFilterMix(c,fc,sub,sub,contact,sumtype,matcheck,tp,...)
	if matcheck~=0 and not matcheck(c,fc,sub,sub2,mg,sg,tp,contact,sumtype,sumtype) then return false end
	if contact then
		if not c:IsCanBeFusionMaterial(fc,tp) then return false end
	else
		if not c:IsCanBeFusionMaterial(fc) then return false end
	end
	for i,f in ipairs({...}) do
		if f(c,fc,sub,sub2,mg,sg,tp,contact,sumtype) then return true end
	end
	return false
end
function Fusion.CheckMix(c,mg,sg,fc,sub,sub2,contact,sumtype,tp,fun1,fun2,...)
	if fun2 then
		sg:AddCard(c)
		local res=false
		if fun1(c,fc,false,sub2,mg,sg,tp,contact,sumtype) then
			res=mg:IsExists(Fusion.CheckMix,1,sg,mg,sg,fc,sub,sub2,contact,sumtype,tp,fun2,...)
		elseif sub and fun1(c,fc,true,sub2,mg,sg,tp,contact,sumtype) then
			res=mg:IsExists(Fusion.CheckMix,1,sg,mg,sg,fc,false,sub2,contact,sumtype,tp,fun2,...)
		end
		sg:RemoveCard(c)
		return res
	else
		return fun1(c,fc,sub,sub2,mg,sg,tp,contact,sumtype)
	end
end
Fusion.CheckExact=nil
Fusion.CheckAdditional=nil
--if sg1 is subset of sg2 then not Fusion.CheckAdditional(tp,sg1,fc) -> not Fusion.CheckAdditional(tp,sg2,fc)
function Fusion.CheckMixGoal(tp,sg,fc,sub,sub2,contact,sumtype,chkf,...)
	local g=Group.CreateGroup()
	return sg:IsExists(Fusion.CheckMix,1,nil,sg,g,fc,sub,sub2,contact,sumtype,tp,...) and (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0)
		and (not Fusion.CheckAdditional or Fusion.CheckAdditional(tp,sg,fc))
end
function Fusion.SelectMix(c,tp,mg,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,...)
	local res
	if (Fusion.CheckExact and (Fusion.CheckExact~=#{...} or #mustg>Fusion.CheckExact)) or #mustg>#{...} then return false end
	-- local rg=Group.CreateGroup()
	local mg2=mg:Clone()
	--c has the fusion limit
	if not contact and c:IsHasEffect(EFFECT_FUSION_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
		for i,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
				return false
			end
			local sg2=mg2:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			-- rg:Merge(sg2)
			mg2:Sub(sg2)
			if #mustg>0 and not mg2:Includes(mustg) then
				return false
			end
		end
	end
	--A card in the selected group has the fusion lmit
	if not contact then
		local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_FUSION_MAT_RESTRICTION)
		for tc in aux.Next(g2) do
			local eff={tc:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
			for i,f in ipairs(eff) do
				if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
					return false
				end
			end
		end
	end
	-- mg2:Sub(rg)
	sg:AddCard(c)
	if #sg<#{...} then
		res=mg2:IsExists(Fusion.SelectMix,1,sg,tp,mg2,sg,mustg-sg,fc,sub,sub2,contact,sumtype,chkf,...)
	else
		res=Fusion.CheckMixGoal(tp,sg,fc,sub,sub2,contact,sumtype,chkf,...)
	end
	res = res and sg:Includes(mustg)
	sg:RemoveCard(c)
	-- mg2:Merge(rg)
	return res
end
--Fusion monster, mixed material * minc to maxc + material + ...
function Fusion.AddProcMixRep(c,sub,insf,fun1,minc,maxc,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local val={fun1,...}
	local fun={}
	local mat={}
	for i=1,#val do
		if type(val[i])=='function' then
			fun[i]=function(c,fc,sub,sub2,mg,sg,tp,contact,sumtype) return (val[i](c,fc,sumtype,tp,sub,mg,sg,contact) or (sub2 and c:IsHasEffect(511002961))) and not c:IsHasEffect(6205579) end
		elseif type(val[i])=='table' then
			fun[i]=Fusion.ParseMaterialTable(val[i],mat)
		else
			local addmat=true
			fun[i]=function(c,fc,sub,sub2,mg,sg,tp,contact,sumtype) return c:IsSummonCode(fc,sumtype,fc:GetControler(),val[i]) or (sub and c:CheckFusionSubstitute(fc)) or (sub2 and c:IsHasEffect(511002961)) end
			for index, value in ipairs(mat) do
				if value==val[i] then
					addmat=false
				end
			end
			if addmat then table.insert(mat,val[i]) end
		end
	end
	if c.material_count==nil then
		local mt=c:GetMetatable()
		if #mat>0 then
			mt.material_count=#mat
			mt.material=mat
		end
		mt.min_material_count=minc+#{...}
		mt.max_material_count=maxc+#{...}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Fusion.ConditionMixRep(insf,sub,fun[1],minc,maxc,table.unpack(fun,2)))
	e1:SetOperation(Fusion.OperationMixRep(insf,sub,fun[1],minc,maxc,table.unpack(fun,2)))
	c:RegisterEffect(e1)
	return {e1}
end
function Fusion.ConditionMixRep(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return	function(e,g,gc,chkfnf)
				local mustg=nil
				if g==nil then
					mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,nil,REASON_FUSION)
				return insf and #mustg==0 end
				local chkf=chkfnf&0xff
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
				local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
				local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
				local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
				if notfusion then
					sumtype=0
				elseif contact then
					sumtype=MATERIAL_FUSION
				end
				local matcheck=e:GetValue()
				mustg=Auxiliary.GetMustBeMaterialGroup(tp,eg,tp,c,mg,REASON_FUSION)
				if contact then mustg:Clear() end
				local sub=not listedmats and (sub or notfusion) and not contact
				local mg=g:Filter(Fusion.ConditionFilterMix,c,c,sub,sub,contact,sumtype,matcheck,tp,fun1,table.unpack(funs))
				if not mg:Includes(mustg) or mustg:IsExists(aux.NOT(Card.IsCanBeFusionMaterial),1,nil,c) then return false end
				if gc then
					if gc:IsExists(aux.NOT(Card.IsCanBeFusionMaterial),1,nil,c)
						or gc:IsExists(aux.NOT(Fusion.ConditionFilterMix),1,nil,c,sub,sub,contact,sumtype,matcheck,tp,fun1,table.unpack(funs))then return false end
					mustg:Merge(gc)
				end
				local sg=Group.CreateGroup()
				mg:Merge(mustg)
				return mg:IsExists(Fusion.SelectMixRep,1,nil,tp,mg,sg,mustg,c,sub,sub,contact,sumtype,chkf,fun1,minc,maxc,table.unpack(funs)) 
			end
end
function Fusion.OperationMixRep(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local chkf=chkfnf&0xff
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
				local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
				local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
				local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
				if notfusion then
					sumtype=0
				elseif contact then
					sumtype=MATERIAL_FUSION
				end
				local matcheck=e:GetValue()
				local sub=not listedmats and (sub or notfusion) and not contact
				local sg=Group.CreateGroup()
				local mg=eg:Filter(Fusion.ConditionFilterMix,c,c,sub,sub,contact,sumtype,matcheck,tp,fun1,table.unpack(funs))
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,eg,tp,c,mg,REASON_FUSION)
				if contact then mustg:Clear() end
				if not mg:Includes(mustg) or mustg:IsExists(aux.NOT(Card.IsCanBeFusionMaterial),1,nil,c) then return false end
				if gc then
					mustg:Merge(gc)
				end
				sg:Merge(mustg)
				local p=tp
				local sfhchk=false
				if not contact and Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					p=1-tp Duel.ConfirmCards(1-tp,mg)
					if mg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				end
				while #sg<maxc+#funs do
					local cg=mg:Filter(Fusion.SelectMixRep,sg,tp,mg,sg,mustg,c,sub,sub,contact,sumtype,chkf,fun1,minc,maxc,table.unpack(funs))
					if #cg==0 then break end
					local finish=Fusion.CheckMixRepGoal(tp,sg,mustg,c,sub,sub,contact,sumtype,chkf,fun1,minc,maxc,table.unpack(funs)) and not Fusion.CheckExact
					local cancel=(contact and #sg==0) and not Fusion.CheckExact
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					local tc=Group.SelectUnselect(cg,sg,p,finish,cancel)
					if not tc then break end
					if #mustg==0 or not mustg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
						else
							sg:RemoveCard(tc)
						end
					end
				end
				if sfhchk then Duel.ShuffleHand(tp) end
				Duel.SetFusionMaterial(sg)
			end
end
function Fusion.CheckMixRep(sg,g,fc,sub,sub2,contact,sumtype,chkf,tp,fun1,minc,maxc,fun2,...)
	if fun2 then
		return sg:IsExists(Fusion.CheckMixRepFilter,1,g,sg,g,fc,sub,sub2,contact,sumtype,chkf,tp,fun1,minc,maxc,fun2,...)
	else
		local ct1=sg:FilterCount(fun1,g,fc,sub,sub2,mg,sg,tp,contact,sumtype)
		local ct2=sg:FilterCount(fun1,g,fc,false,sub2,mg,sg,tp,contact,sumtype)
		return ct1==#sg-#g and ct1-ct2<=1
	end
end
function Fusion.CheckMixRepFilter(c,sg,g,fc,sub,sub2,contact,sumtype,chkf,tp,fun1,minc,maxc,fun2,...)
	if fun2(c,fc,sub,sub2,mg,sg,tp,contact,sumtype) then
		g:AddCard(c)
		local sub=sub and fun2(c,fc,false,sub2,contact,sumtype,mg,sg,tp)
		local res=Fusion.CheckMixRep(sg,g,fc,sub,sub2,contact,sumtype,chkf,tp,fun1,minc,maxc,...)
		g:RemoveCard(c)
		return res
	end
	return false
end
function Fusion.CheckMixRepGoal(tp,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...)
	if #sg<minc+#{...} or #sg>maxc+#{...} then return false end
	local g=Group.CreateGroup()
	return Fusion.CheckMixRep(sg,g,fc,sub,sub2,contact,sumtype,chkf,tp,fun1,minc,maxc,...) and (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0)
		and (not Fusion.CheckAdditional or Fusion.CheckAdditional(tp,sg,fc))
end
function Fusion.CheckMixRepTemplate(c,cond,tp,mg,sg,mustg,g,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...)
	for i,f in ipairs({...}) do
		if f(c,fc,sub,sub2,mg,sg,tp,contact,sumtype) then
			g:AddCard(c)
			local sub=sub and f(c,fc,false,sub2,mg,sg,tp,contact,sumtype)
			local t={...}
			table.remove(t,i)
			local res=cond(tp,mg,sg,mustg-c,g,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,table.unpack(t))
			g:RemoveCard(c)
			if res then return true end
		end
	end
	if maxc>0 then
		if fun1(c,fc,sub,sub2,mg,sg,tp,contact,sumtype) then
			g:AddCard(c)
			local sub=sub and fun1(c,fc,false,sub2,mg,sg,tp,contact,sumtype)
			local res=cond(tp,mg,sg,mustg-c,g,fc,sub,sub2,contact,sumtype,chkf,fun1,minc-1,maxc-1,...)
			g:RemoveCard(c)
			if res then return true end
		end
	end
	return false
end
function Fusion.CheckMixRepSelectedCond(tp,mg,sg,mustg,g,...)
	if #g<#sg then
		return sg:IsExists(Fusion.CheckMixRepSelected,1,g,tp,mg,sg,mustg,g,...)
	else
		return Fusion.CheckSelectMixRep(tp,mg,sg,mustg,g,...)
	end
end
function Fusion.CheckMixRepSelected(c,...)
	return Fusion.CheckMixRepTemplate(c,Fusion.CheckMixRepSelectedCond,...)
end
function Fusion.CheckSelectMixRep(tp,mg,sg,mustg,g,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...)
	if Fusion.CheckAdditional and not Fusion.CheckAdditional(tp,g,fc) then return false end
	if chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,g,fc)>0 then
		if minc<=0 and #{...}==0 and g:Includes(mustg) then return true end
		return mg:IsExists(Fusion.CheckSelectMixRepAll,1,g,tp,mg,sg,mustg,g,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...)
	else
		return mg:IsExists(Fusion.CheckSelectMixRepM,1,g,tp,mg,sg,mustg,g,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...)
	end
end
function Fusion.CheckSelectMixRepAll(c,tp,mg,sg,mustg,g,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,fun2,...)
	if fun2 then
		if fun2(c,fc,sub,sub2,mg,sg,tp,contact,sumtype) then
			g:AddCard(c)
			local sub=sub and fun2(c,fc,false,sub2,mg,sg,tp,contact,sumtype)
			local res=Fusion.CheckSelectMixRep(tp,mg,sg,mustg,g,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...)
			g:RemoveCard(c)
			return res
		end
	elseif maxc>0 and fun1(c,fc,sub,sub2,mg,sg,tp,contact,sumtype) then
		g:AddCard(c)
		local sub=sub and fun1(c,fc,false,sub2,mg,sg,tp,contact,sumtype)
		local res=Fusion.CheckSelectMixRep(tp,mg,sg,mustg,g,fc,sub,sub2,contact,sumtype,chkf,fun1,minc-1,maxc-1)
		g:RemoveCard(c)
		return res
	end
	return false
end
function Fusion.CheckSelectMixRepM(c,tp,...)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and Fusion.CheckMixRepTemplate(c,Fusion.CheckSelectMixRep,tp,...)
end
function Fusion.SelectMixRep(c,tp,mg,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...)
	local mg2=mg:Clone()
	-- local rg=Group.CreateGroup()
	if Fusion.CheckExact then
		if Fusion.CheckExact<minc + #{...} or #mustg>Fusion.CheckExact then return false end
		maxc=Fusion.CheckExact-#{...}
		minc=Fusion.CheckExact-#{...}
	end
	--c has the fusion limit
	if not contact and c:IsHasEffect(EFFECT_FUSION_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
		for i,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
				-- mg:Merge(rg)
				return false
			end
			local sg2=mg2:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			-- rg:Merge(sg2)
			mg2:Sub(sg2)
			if #mustg>0 and not mg2:Includes(mustg) then
				return false
			end
		end
	end
	--A card in the selected group has the fusion lmit
	if not contact then
		local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_FUSION_MAT_RESTRICTION)
		for tc in aux.Next(g2) do
			local eff={tc:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
			for i,f in ipairs(eff) do
				if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
					-- mg:Merge(rg)
					return false
				end
			end
		end
	end
	sg:AddCard(c)
	local res=false
	if Fusion.CheckAdditional and not Fusion.CheckAdditional(tp,sg,fc) then
		res=false
	elseif Fusion.CheckMixRepGoal(tp,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...) then
		res=true
	else
		local g=Group.CreateGroup()
		res=sg:IsExists(Fusion.CheckMixRepSelected,1,nil,tp,mg2,sg,mustg,g,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...)
	end
	sg:RemoveCard(c)
	-- mg:Merge(rg)
	return res
end


function Fusion.AddProcMixRepUnfix(c,sub,insf,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local val={...}
	local fun={}
	local mat={}
	local minc=0
	local maxc=0
	for i=1,#val do
		local f=val[i]
		if type(f[1])=='function' then
			fun[i]={function(c,fc,sub,sub2,mg,sg,tp,contact,sumtype)
			return (f[1](c,fc,sumtype,tp,sub,mg,sg,contact) or (sub2 and c:IsHasEffect(511002961))) and not c:IsHasEffect(6205579) end,f[2], f[3]}
		elseif type(f[1])=='table' then
			fun[i]={Fusion.ParseMaterialTable(f[1],mat),f[2],f[3]}
		else
			local addmat=true
			fun[i]={function(c,fc,sub,sub2,mg,sg,tp,contact,sumtype) return c:IsSummonCode(fc,sumtype,fc:GetControler(),f[1]) or (sub and c:CheckFusionSubstitute(fc)) or (sub2 and c:IsHasEffect(511002961)) end,f[2], f[3]}
			for index, value in ipairs(mat) do
				if value==f[1] then
					addmat=false
				end
			end
			if addmat then table.insert(mat,f[1]) end
		end
		minc=minc+f[2]
		maxc=maxc+f[3]
	end
	if c.material_count==nil then
		local mt=c:GetMetatable()
		if #mat>0 then
			mt.material_count=#mat
			mt.material=mat
		end
		mt.min_material_count=#{...}
		mt.max_material_count=#{...}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Fusion.ConditionMixRepUnfix(insf,sub,minc,maxc,table.unpack(fun)))
	e1:SetOperation(Fusion.OperationMixRepUnfix(insf,sub,minc,maxc,table.unpack(fun)))
	c:RegisterEffect(e1)
end
function Fusion.ConditionMixRepUnfix(insf,sub,minc,maxc,...)
	--g:Material group(nil for Instant Fusion)
	--gc:Material already used
	--chkf: check field, default:PLAYER_NONE
	local funs={...}
	return	function(e,g,gc,chkfnf)
				local mustg=nil
				if g==nil then
					mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,nil,REASON_FUSION)
				return insf and #mustg==0 end
				local chkf=chkfnf&0xff
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
				local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
				local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
				local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
				if notfusion then
					sumtype=0
				elseif contact then
					sumtype=MATERIAL_FUSION
				end
				local matcheck=e:GetValue()
				local sub=not listedmats and (sub or notfusion) and not contact
				local mg=g:Filter(Fusion.ConditionFilterMixRepUnfix,c,c,sub,sub,contact,sumtype,tp,table.unpack(funs))
				mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_FUSION)
				if contact then mustg:Clear() end
				if not mg:Includes(mustg) or mustg:IsExists(aux.NOT(Card.IsCanBeFusionMaterial),1,nil,c) then return false end
				if gc then
					if gc:IsExists(aux.NOT(Card.IsCanBeFusionMaterial),1,nil,c) then return false end
					mustg:Merge(gc)
				end
				local sg=Group.CreateGroup()
				mg:Merge(mustg)
				return mg:IsExists(Fusion.SelectMixRepUnfix,1,nil,tp,mg,sg,mustg,c,sub,sub,minc,maxc,chkf,table.unpack(funs))
			end
end
function Fusion.OperationMixRepUnfix(insf,sub,minc,maxc,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local chkf=chkfnf&0xff
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
				local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
				local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
				local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
				if notfusion then
					sumtype=0
				elseif contact then
					sumtype=MATERIAL_FUSION
				end
				local matcheck=e:GetValue()
				local sub=not listedmats and (sub or notfusion) and not contact
				local mg=eg:Filter(Fusion.ConditionFilterMixRepUnfix,c,c,sub,sub,contact,sumtype,tp,table.unpack(funs))
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,eg,tp,c,mg,REASON_FUSION)
				if contact then mustg:Clear() end
				local sg=Group.CreateGroup()
				if gc then
					mustg:Merge(gc)
				end
				for tc in aux.Next(mustg) do
					sg:AddCard(tc)
					if not contact and tc:IsHasEffect(EFFECT_FUSION_MAT_RESTRICTION) then
						local eff={gc:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
						for i=1,#eff do
							local f=eff[i]:GetValue()
							mg=mg:Filter(aux.NOT(Auxiliary.HarmonizingMagFilter),tc,eff[i],f)
						end
					end
				end
				local p=tp
				local sfhchk=false
				if not contact and Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					p=1-tp Duel.ConfirmCards(1-tp,mg)
					if mg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				end
				while #sg<maxc do
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
					local cg=mg:Filter(Fusion.SelectMixRepUnfix,sg,tp,mg,sg,mustg:Filter(aux.TRUE,sg),c,sub,sub,minc,maxc,chkf,table.unpack(funs))
					if #cg==0 then break end
					local finish=(sg:IsExists(Fusion.CheckMixRepUnfixSelected,1,nil,tp,sg,sg,mustg,Group.CreateGroup(),c,sub,sub2,chkf,minc,maxc,table.unpack(funs))) and not Fusion.CheckExact
					local cancel=(contact and #sg==0) and not Fusion.CheckExact
					local tc=Group.SelectUnselect(cg,sg,p,finish,cancel,minc,maxc)
					if not tc then break end
					if #mustg==0 or not mustg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
						else
							sg:RemoveCard(tc)
						end
					end
				end
				if sfhchk then Duel.ShuffleHand(tp) end
				Duel.SetFusionMaterial(sg)
			end
end
function Fusion.ConditionFilterMixRepUnfix(c,fc,sub,sub,contact,sumtype,tp,...)
	if contact then
		if not c:IsCanBeFusionMaterial(fc,tp) then return false end
	else
		if not c:IsCanBeFusionMaterial(fc) then return false end
	end
	for i,f in ipairs({...}) do
		if f[1](c,fc,sub,sub2,mg,sg,tp) then return true end
	end
	return false
end
function Fusion.CheckMixRepUnfixTemplate(c,cond,tp,mg,sg,mustg,g,fc,sub,sub2,chkf,minc,maxc,...)
	if maxc==0 then return false end
	for i,f in ipairs({...}) do
		if f[1](c,fc,sub,sub2,mg,sg,tp) then
			g:AddCard(c)
			local sub=sub and f[1](c,fc,false,sub2,mg,sg,tp)
			local t={...}
			local min=f[2]-1
			local max=f[3]-1
			if max>0 then
				t[i]={f[1],min,max}
			else
				table.remove(t,i)
			end
			local mina=minc
			if min>=0 then
				mina=mina-1
			end
			local res=cond(tp,mg,sg,mustg,g,fc,sub,sub2,chkf,mina,maxc-1,table.unpack(t))
			if not res and min<1 then
				if max<1 then
					table.remove(t,i)
				end
				res=cond(tp,mg,sg,mustg,g,fc,sub,sub2,chkf,mina,maxc-1,table.unpack(t))
			end
			g:RemoveCard(c)
			if res then return true end
		end
	end
	return false
end
function Fusion.CheckMixRepUnfixSelectedCond(tp,mg,sg,mustg,g,...)
	if #g<#sg then
		return sg:IsExists(Fusion.CheckMixRepUnfixSelected,1,g,tp,mg,sg,mustg,g,...)
	else
		return Fusion.CheckSelectMixRepUnfix(tp,mg,sg,mustg,g,...)
	end
end
function Fusion.CheckMixRepUnfixSelected(c,...)
	return Fusion.CheckMixRepUnfixTemplate(c,Fusion.CheckMixRepUnfixSelectedCond,...)
end
function Fusion.CheckSelectMixRepUnfix(tp,mg,sg,mustg,g,fc,sub,sub2,chkf,minc,maxc,...)
	if Fusion.CheckAdditional and not Fusion.CheckAdditional(tp,g,fc) then return false end
	if chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,g,fc)>0 then
		if minc<=0 and g:Includes(mustg) then return true end
		return mg:IsExists(Fusion.CheckSelectMixRepUnfixAll,1,g,tp,mg,sg,mustg,g,fc,sub,sub2,chkf,minc,maxc,...)
	else
		return mg:IsExists(Fusion.CheckSelectMixRepUnfixM,1,g,tp,mg,sg,mustg,g,fc,sub,sub2,chkf,minc,maxc,...)
	end
end
function Fusion.CheckSelectMixRepUnfixAll(c,tp,mg,sg,mustg,g,fc,sub,sub2,chkf,minc,maxc,...)
	if maxc==0 then return false end
	--Second layer check for harmonizing magician, checking teh possible selected group for the fusion summon
	local mg2=mg:Clone()
	if not contact then
		if c:IsHasEffect(EFFECT_FUSION_MAT_RESTRICTION) then
			local eff={c:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
			for _,fun in ipairs(eff) do
				if (sg+g):IsExists(Auxiliary.HarmonizingMagFilter,1,c,fun,fun:GetValue()) then
					return false
				end
				local sg2=mg2:Filter(Auxiliary.HarmonizingMagFilter,nil,fun,fun:GetValue())
				mg2:Sub(sg2)
			end
		end
		local g2=(sg+g):Filter(Card.IsHasEffect,nil,EFFECT_FUSION_MAT_RESTRICTION)
		for tc in aux.Next(g2) do
			local eff={tc:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
			for _,fun in ipairs(eff) do
				if Auxiliary.HarmonizingMagFilter(c,fun,fun:GetValue()) then
					return false
				end
			end
		end
	end
	for i,f in ipairs({...}) do
		if f[1](c,fc,sub,sub2,mg2,sg,tp) then
			g:AddCard(c)
			local sub=sub and f[1](c,fc,false,sub2,mg2,sg,tp)
			local t={...}
			local min=f[2]-1
			local max=f[3]-1
			if max>0 then
				t[i]={f[1],min,max}
			else
				table.remove(t,i)
			end
			local mina=minc
			if min>=0 then
				mina=mina-1
			end
			local res=Fusion.CheckSelectMixRepUnfix(tp,mg2,sg,mustg,g,fc,sub,sub2,chkf,mina,maxc-1,table.unpack(t))
			if not res and min<1 then
				if max<1 then
					table.remove(t,i)
				end
				res=Fusion.CheckSelectMixRepUnfix(tp,mg2,sg,mustg,g,fc,sub,sub2,chkf,mina,maxc-1,table.unpack(t))
			end
			g:RemoveCard(c)
			if res then return true end
		end
	end
	return false
end
function Fusion.CheckSelectMixRepUnfixM(c,tp,...)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and Fusion.CheckMixRepUnfixTemplate(c,Fusion.CheckSelectMixRepUnfix,tp,...)
end
function Fusion.SelectMixRepUnfix(c,tp,mg,sg,mustg,fc,sub,sub2,minc,maxc,chkf,...)
	local rg=Group.CreateGroup()
	if Fusion.CheckExact then
		if Fusion.CheckExact<minc or #mustg>Fusion.CheckExact then return false end
		maxc=Fusion.CheckExact
		minc=Fusion.CheckExact
	end
	--First layer check for harmonizing magician, checking only the selected group given when the function is called
	--c has the fusion limit
	if c:IsHasEffect(EFFECT_FUSION_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
		for i,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
				mg:Merge(rg)
				return false
			end
			local sg2=mg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			rg:Merge(sg2)
			mg:Sub(sg2)
		end
	end
	--A card in the selected group has the fusion lmit
	local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_FUSION_MAT_RESTRICTION)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
		for i,f in ipairs(eff) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
				mg:Merge(rg)
				return false
			end
		end
	end
	sg:AddCard(c)
	local res=false
	if Fusion.CheckAdditional and not Fusion.CheckAdditional(tp,sg,fc) then
		res=false
	else
		local g=Group.CreateGroup()
		res=sg:IsExists(Fusion.CheckMixRepUnfixSelected,1,nil,tp,mg,sg,mustg,g,fc,sub,sub2,chkf,minc,maxc,...)
	end
	sg:RemoveCard(c)
	mg:Merge(rg)
	return res
end


function Fusion.AddContactProc(c,group,op,sumcon,condition,sumtype,desc)
	local mt=c.__index
	local t={}
	if mt.contactfus then
		t=mt.contactfus
	end
	t[c]=true
	mt.contactfus=t
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	if not desc then
		e1:SetDescription(2)
	else
		e1:SetDescription(desc)
	end
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	if sumtype then
		e1:SetValue(sumtype)
	end
	e1:SetCondition(Fusion.ContactCon(group,condition))
	e1:SetTarget(Fusion.ContactTg(group))
	e1:SetOperation(Fusion.ContactOp(op))
	c:RegisterEffect(e1)
	if sumcon then
		--spsummon condition
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCode(EFFECT_SPSUMMON_CONDITION)
		if type(sumcon)=='function' then
			e2:SetValue(sumcon)
		end
		c:RegisterEffect(e2)
	end
end
function Fusion.ContactCon(f,fcon)
	return function(e,c)
		if c==nil then return true end
		local m=f(e:GetHandlerPlayer())
		local chkf=c:GetControler()|FUSPROC_CONTACTFUS
		return c:CheckFusionMaterial(m,nil,chkf) and (not fcon or fcon(e:GetHandlerPlayer()))
	end
end
function Fusion.ContactTg(f)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local m=f(tp)
		local chkf=tp|FUSPROC_CONTACTFUS
		local sg=Duel.SelectFusionMaterial(tp,e:GetHandler(),m,nil,chkf)
		if #sg>0 then
			sg:KeepAlive()
			e:SetLabelObject(sg)
			return true
		else return false end
	end
end
function Fusion.ContactOp(f)
	return function(e,tp,eg,ep,ev,re,r,rp,c)
		local g=e:GetLabelObject()
		c:SetMaterial(g)
		f(g,tp,c)
		g:DeleteGroup()
	end
end
--Fusion monster, name + name
function Fusion.AddProcCode2(c,code1,code2,sub,insf)
	return Fusion.AddProcMix(c,sub,insf,code1,code2)
end
--Fusion monster, name + name + name
function Fusion.AddProcCode3(c,code1,code2,code3,sub,insf)
	return Fusion.AddProcMix(c,sub,insf,code1,code2,code3)
end
--Fusion monster, name + name + name + name
function Fusion.AddProcCode4(c,code1,code2,code3,code4,sub,insf)
	return Fusion.AddProcMix(c,sub,insf,code1,code2,code3,code4)
end
--Fusion monster, name * n
function Fusion.AddProcCodeRep(c,code1,cc,sub,insf)
	local code={}
	for i=1,cc do
		code[i]=code1
	end
	return Fusion.AddProcMix(c,sub,insf,table.unpack(code))
end
--Fusion monster, name * minc to maxc
function Fusion.AddProcCodeRep2(c,code1,minc,maxc,sub,insf)
	return Fusion.AddProcMixRep(c,sub,insf,code1,minc,maxc)
end
--Fusion monster, name + condition * n
function Fusion.AddProcCodeFun(c,code1,f,cc,sub,insf)
	local fun={}
	for i=1,cc do
		fun[i]=f
	end
	return Fusion.AddProcMix(c,sub,insf,code1,table.unpack(fun))
end
--Fusion monster, condition + condition
function Fusion.AddProcFun2(c,f1,f2,insf)
	return Fusion.AddProcMix(c,false,insf,f1,f2)
end
--Fusion monster, condition * n
function Fusion.AddProcFunRep(c,f,cc,insf)
	local fun={}
	for i=1,cc do
		fun[i]=f
	end
	return Fusion.AddProcMix(c,false,insf,table.unpack(fun))
end
--Fusion monster, condition * minc to maxc
function Fusion.AddProcFunRep2(c,f,minc,maxc,insf)
	return Fusion.AddProcMixRep(c,false,insf,f,minc,maxc)
end
--Fusion monster, condition1 + condition2 * n
function Fusion.AddProcFunFun(c,f1,f2,cc,insf)
	local fun={}
	for i=1,cc do
		fun[i]=f2
	end
	return Fusion.AddProcMix(c,false,insf,f1,table.unpack(fun))
end
--Fusion monster, condition1 + condition2 * minc to maxc
function Fusion.AddProcFunFunRep(c,f1,f2,minc,maxc,insf)
	return Fusion.AddProcMixRep(c,false,insf,f2,minc,maxc,f1)
end
--Fusion monster, name + condition * minc to maxc
function Fusion.AddProcCodeFunRep(c,code1,f,minc,maxc,sub,insf)
	return Fusion.AddProcMixRep(c,sub,insf,f,minc,maxc,code1)
end
--Fusion monster, name + name + condition * minc to maxc
function Fusion.AddProcCode2FunRep(c,code1,code2,f,minc,maxc,sub,insf)
	return Fusion.AddProcMixRep(c,sub,insf,f,minc,maxc,code1,code2)
end
--Fusion monster, any number of name/condition * n - fixed
function Fusion.AddProcMixN(c,sub,insf,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local val={...}
	local t={}
	local n={}
	if #val%2~=0 then return end
	for i=1,#val do
		if i%2~=0 then
			table.insert(t,val[i])
		else
			table.insert(n,val[i])
		end
	end
	if #t~=#n then return end
	local fun={}
	for i=1,#t do
		for j=1,n[i] do
			table.insert(fun,t[i])
		end
	end
	return Fusion.AddProcMix(c,sub,insf,table.unpack(fun))
end
Duel.LoadScript("proc_fusion2.lua")
